# ...existing code...
# ...existing code...
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/database.sh
source $SCRIPT_DIR/helper.sh
source $SCRIPT_DIR/metadata.sh
source $SCRIPT_DIR/sqlhandler.sh
source $SCRIPT_DIR/table.sh
function parseQuery() {
    # disable globbing (metacharacters)
    # because the query may contain special characters like "*"
    set -f
    # check if the query is empty
    if [[ -z $1 ]]; then
        print "Error: Query is empty" "white" "red"
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
        table=$(echo $1 | grep -ioP '(?<=from )[a-zA-Z0-9_]+(?= where|;|$)')
        conditions=$(echo $1 | grep -ioP '(?<=where ).*(?=[;$]?)')

        # split the columns into an array
        IFS=',' read -r -a columns <<< "$columns"
        columns_array=()
        for column in "${columns[@]}"; do
            # remove spaces
            column=$(echo $column | xargs)
            columns_array+=("$column")
        done
        sqlSelectFromTable $table columns_array "$conditions"
    elif [[ $1 =~ ^[[:space:]]*[dD][eE][lL][eE][tT][eE] ]]; then
        table=$(echo $1 | grep -ioP '(?<=from )[a-zA-Z0-9_]+(?= where|$)')
        conditions=$(echo $1 | grep -ioP '(?<=where ).*(?=[;$]?)')
        sqlDeleteFromTable $table "$conditions"
        return
    elif [[ $1 =~ ^[[:space:]]*[uU][pP][dD][aA][tT][eE] ]]; then
        # echo "Update query"
        table=$(echo $1 | grep -ioP '(?<=update )[a-zA-Z0-9_]+(?= set)')
        set_clause=$(echo $1 | grep -ioP '(?<=set ).*(?= where)')
        conditions=$(echo $1 | grep -ioP '(?<=where )[^;]*(?=[$;]?)')
        # echo $table
        # echo $set_clause
        # echo $conditions
        # split the set clause into columns and values
        IFS=',' read -r -a set_array <<< "$set_clause"
        # echo ${set_array[@]}
        columns=()
        values=()
        for set in "${set_array[@]}"; do
            # remove spaces
            set=$(echo $set | xargs)
            IFS='=' read -r -a set_array <<< "$set"
            columns+=("${set_array[0]}")
            values+=("${set_array[1]}")
        done
        sqlUpdateTable $table columns values "$conditions"
        return
    elif [[ $1 =~ ^[[:space:]]*[iI][nN][sS][eE][rR][tT] ]]; then
        # echo "Insert query"
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
        # echo "Drop query"
        table=$(echo $1 | grep -ioP '(?<=table )[a-zA-Z0-9_]+(?=[;$]?)')
        dropTable $table
        return
    elif [[ $1 =~ ^[[:space:]]*[cC][rR][eE][aA][tT][eE][[:space:]]+[tT][aA][bB][lL][eE] ]]; then
        # Extract the table name (after CREATE TABLE and before the parentheses)
        tableName=$(echo $1 | grep -ioP '(?<=create table )[a-zA-Z0-9_]+(?=\s*\()')
        # echo "Table Name: $tableName"

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
    elif [[ $1 =~ ^[[:space:]]*[aA][lL][tT][eE][rR][[:space:]]+[tT][aA][bB][lL][eE] ]]; then
        # echo "Alter query"
        table=$(echo $1 | grep -ioP '(?<=table )[a-zA-Z0-9_]+(?= add| drop| modify)')
        action=$(echo $1 | grep -ioP '(add|drop|modify)')
        # echo $table
        # echo $action
        if [[ $action =~ [aA][dD][dD] ]]; then
            columnDef=$(echo $1 | grep -oP '(?<=add ).*(?=[;$]?)')
            # echo $columnDef
            # split over the space
            IFS=' ' read -r -a column_names_dt <<< "$columnDef"
            # push the column name to the column_names array
            column_name="${column_names_dt[0]}"
            # handling the data type
            if [[ ${column_names_dt[1]} =~ [iI][nN][tT] ]]; then
                column_type="int"
                column_size="4"
            elif [[ ${column_names_dt[1]} =~ [vV][aA][rR][cC][hH][aA][rR] ]]; then
                column_type="varchar"
                column_size=$(echo $columnDef | grep -oP '(?<=\().*(?=\))' | grep -oP '[0-9]+')
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
            # handling default value
            default=""
            if [[ $columnDef =~ [dD][eE][fF][aA][uU][lL][tT] ]]; then
                default=$(echo $columnDef | grep -oP '(?<=default )[^;]*(?=[;|$]?)')
            fi
            alterTableAddColumn $tableName $columnName $columnType $columnLength $constraint $default
        elif [[ $action =~ [dD][rR][oO][pP] ]]; then
            column=$(echo $1 | grep -ioP '(?<=drop column )[a-zA-Z0-9_]+(?=[;$]?)')
            alterTableDropColumn $table $column
        elif [[ $action =~ [mM][oO][dD][iI][fF][yY] ]]; then
            columnDef=$(echo $1 | grep -oP '(?<=modify ).*(?=[;$]?)')
            # echo $columnDef
            # split over the space
            IFS=' ' read -r -a column_names_dt <<< "$columnDef"
            # push the column name to the column_names array
            column_name="${column_names_dt[0]}"
            # handling the data type
            if [[ ${column_names_dt[1]} =~ [iI][nN][tT] ]]; then
                column_type="int"
                column_size="4"
            elif [[ ${column_names_dt[1]} =~ [vV][aA][rR][cC][hH][aA][rR] ]]; then
                column_type="varchar"
                column_size=$(echo $columnDef | grep -oP '(?<=\().*(?=\))' | grep -oP '[0-9]+')
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
            sqlalterTable $table "modify" $column_name $column_type $column_size $constraint
        elif [[ $1 =~ ^[[:space:]]*[cC][lL][eE][aA][rR] ]]; then
            clear
        fi
    else
        print "Error: Invalid query" "white" "red"
        return
    fi
    set +f
}

# create table query
# parseQuery "use database iti"
# parseQuery "select id from emp where name = 'lol lol';"
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
#     drop database iti;
# "

# alter table query
# parseQuery "alter      table 
#     emp 
#         add
        
#          email
#           varchar ( 30 ) not   null   unique primary key default 3;"

# parseQuery "use database iti"

# parseQuery "alter table emp drop column name;"

# echo $(getColumnIndex "emp" "name")