source ./sqlhandler.sh
source ./database.sh
function parseQuery() {
    # disable globbing (metacharacters)
    # because the query may contain special characters like "*"
    set -f
    # check if the query is empty
    if [[ -z $1 ]]; then
        print "Query is empty" "white" "red"
        return
    fi
    ###############################################################
    #                     database queries                        #
    ###############################################################
    if [[ $1 =~ ^[[:space:]]*[cC][rR][eE][aA][tT][eE][[:space:]]+[dD][aA][tT][aA][bB][aA][sS][eE] ]]; then
        dbName=$(echo $1 | grep -ioP '(?<=database )[a-zA-Z0-9_]+(?=[;$]?)')
        createDatabase $dbName
        return
    elif [[ $1 =~ ^[[:space:]]*[dD][rR][oO][pP][[:space:]]+[dD][aA][tT][aA][bB][aA][sS][eE] ]]; then
        dbName=$(echo $1 | grep -ioP '(?<=database )[a-zA-Z0-9_]+(?=[;$]?)')
        dropDatabase $dbName
        return
    elif [[ $1 =~ ^[[:space:]]*[uU][sS][eE][[:space:]]+[dD][aA][tT][aA][bB][aA][sS][eE] ]]; then
        dbName=$(echo $1 | grep -ioP '(?<=database )[a-zA-Z0-9_]+(?=[;$]?)')
        connectToDatabase $dbName
        return
    elif [[ $1 =~ ^[[:space:]]*[sS][hH][oO][wW][[:space:]]+[dD][aA][tT][aA][bB][aA][sS][eE][sS] ]]; then
        set +f
        listDatabases
        set -f
        return
    ###############################################################
    #                     Tables queries                          #
    ###############################################################
    elif [[ $1 =~ ^[[:space:]]*[sS][eE][lL][eE][cC][tT] ]]; then
        columns=$(echo $1 | grep -ioP '(?<=select ).*(?= from)')
        table=$(echo $1 | grep -ioP '(?<=from )[a-zA-Z0-9_]+(?= where|$)')
        conditions=$(echo $1 | grep -ioP '(?<=where ).*(?=[;$]?)')
        echo $columns
        echo $table
        echo $conditions
    elif [[ $1 =~ ^[[:space:]]*[dD][eE][lL][eE][tT][eE] ]]; then
        table=$(echo $1 | grep -ioP '(?<=from )[a-zA-Z0-9_]+(?= where|$)')
        conditions=$(echo $1 | grep -ioP '(?<=where ).*(?=[;$]?)')
        echo $table
        echo $conditions
        return
    elif [[ $1 =~ ^[[:space:]]*[uU][pP][dD][aA][tT][eE] ]]; then
        echo "Update query"
        table=$(echo $1 | grep -ioP '(?<=update )[a-zA-Z0-9_]+(?= set)')
        set_clause=$(echo $1 | grep -ioP '(?<=set ).*(?= where)')
        conditions=$(echo $1 | grep -ioP '(?<=where )[^;]*(?=[$;]?)')
        echo $table
        echo $set_clause
        echo $conditions
        # split the set clause into columns and values
        IFS=',' read -r -a set_array <<< "$set_clause"
        echo ${set_array[@]}
        columns=()
        values=()
        for set in "${set_array[@]}"; do
            # remove spaces
            set=$(echo $set | tr -d ' ')
            IFS='=' read -r -a set_array <<< "$set"
            columns+=("${set_array[0]}")
            values+=("${set_array[1]}")
        done
        sqlUpdateTable $table columns values "$conditions"
        return
    elif [[ $1 =~ ^[[:space:]]*[iI][nN][sS][eE][rR][tT] ]]; then
        echo "Insert query"
        table=$(echo $1 | grep -ioP '(?<=into )[a-zA-Z0-9_]+(?= \(| values)')
        columns=$(echo $1 | grep -ioP '(?<=\().*(?=\) values)')
        values=$(echo $1 | grep -ioP '(?<=values \().*(?=\))')

        #split the columns and values into arrays
        IFS=',' read -r -a columns <<< "$columns"
        IFS=',' read -r -a values <<< "$values"
        # echo $table
        # echo $columns
        # echo $values
        sqlinsertIntoTable $table columns values
        return
    elif [[ $1 =~ ^[[:space:]]*[dD][rR][oO][pP][[:space:]]+[tT][aA][bB][lL][eE] ]]; then
        echo "Drop query"
        table=$(echo $1 | grep -ioP '(?<=table )[a-zA-Z0-9_]+(?=[;$]?)')
        dropTable $table
        return
    elif [[ $1 =~ ^[[:space:]]*[cC][rR][eE][aA][tT][eE][[:space:]]+[tT][aA][bB][lL][eE] ]]; then
        # Extract the table name (after CREATE TABLE and before the parentheses)
        tableName=$(echo $1 | grep -ioP '(?<=create table )[a-zA-Z0-9_]+(?=\s*\()')
        echo "Table Name: $tableName"

        # Extract column definitions (everything inside the parentheses after CREATE TABLE)
        columnDefs=$(echo $1 | grep -oP '(?<=\().*(?=\))')
        # echo "Column Definitions: $columnDefs"

        # split the column definitions into an array over the comma
        IFS=',' read -r -a columnDefs <<< "$columnDefs"
        # echo "Column Definitions: ${columnDefs[0]}"

        column_names=()
        column_types=()
        column_sizes=()
        column_constraints=()

        # loop through the column definitions
        for columnDef in "${columnDefs[@]}"; do
            # split over the space
            IFS=' ' read -r -a column_names_dt <<< "$columnDef"

            # push the column name to the column_names array
            column_names+=("${column_names_dt[0]}")
            
            # handling the data type
            if [[ ${column_names_dt[1]} =~ [iI][nN][tT] ]]; then
                column_types+=("int")
                column_sizes+=("4")
            elif [[ ${column_names_dt[1]} =~ [vV][aA][rR][cC][hH][aA][rR] ]]; then
                column_types+=("varchar")
                column_sizes+=($(echo $columnDef | grep -oP '(?<=\().*(?=\))' | grep -oP '[0-9]+'))
            fi
            
            # handling the constraints
            constraint=""
            # handling primary key constraint
            if [[ $columnDef =~ [pP][rR][iI][mM][aA][rR][yY] ]]; then
                constraint+='y'
            else
                constraint+='n'
            fi
            # handling not null constraint
            if [[ $columnDef =~ [nN][oO][tT][[:space:]]+[nN][uU][lL][lL] ]]; then 
                constraint+='y'
            else
                constraint+='n'
            fi
            # handling unique constraint
            if [[ $columnDef =~ [uU][nN][iI][qQ][uU][eE] ]]; then
                constraint+='y'
            else
                constraint+='n'
            fi
            column_constraints+=("$constraint")

        done
        # echo "Column Names: ${#column_names[@]}"
        # echo "Column Types: ${#column_types[@]}"
        # echo "Column Sizes: ${#column_sizes[@]}"
        # echo "Column Constraints: ${#$column_constraints[@]}"
        sqlcreateTable $tableName column_names column_types column_sizes column_constraints
        
    elif [[ $1 =~ ^[[:space:]]*[cC][lL][eE][aA][rR] ]]; then
        clear
    else
        print "Invalid query" "white" "red"
        return
    fi
    set +f
}

# create table query
# parseQuery "use database iti"
# parseQuery "create table std ( id int primary key, name varchar ( 40 ) not null , age int not null, email varchar (100) unique);  "

# parseQuery "create table emp ( id int primary key, name varchar (30) );"
# # parseQuery "
# #     create table emp (
# #     id int primary key,
# #     name varchar (30),
# #     email varchar (30) not null unique,
# #     age int not null,
# #     phone varchar(15) unique
# # )
# # "

# parseQuery "
#     update emp set name = adel where id >= 1
# " 