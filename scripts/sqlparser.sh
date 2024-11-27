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
        set=$(echo $1 | grep -ioP '(?<=set ).*(?= where)')
        conditions=$(echo $1 | grep -ioP '(?<=where ).*(?=[;$]?)')
        echo $table
        echo $set
        echo $conditions
        return
    elif [[ $1 =~ ^[[:space:]]*[iI][nN][sS][eE][rR][tT] ]]; then
        echo "Insert query"
        table=$(echo $1 | grep -ioP '(?<=into )[a-zA-Z0-9_]+(?= \(| values)')
        columns=$(echo $1 | grep -ioP '(?<=\().*(?=\) values)')
        values=$(echo $1 | grep -ioP '(?<=values \().*(?=\))')
        echo $table
        echo $values
        return
    elif [[ $1 =~ ^[[:space:]]*[dD][rR][oO][pP][[:space:]]+[tT][aA][bB][lL][eE] ]]; then
        echo "Drop query"
        table=$(echo $1 | grep -ioP '(?<=table )[a-zA-Z0-9_]+(?=[;$]?)')
        echo $table
        return
    elif [[ $1 =~ ^[[:space:]]*[cC][rR][eE][aA][tT][eE][[:space:]]+[tT][aA][bB][lL][eE] ]]; then
        echo "Create table query"
        
        # Extract the table name (after CREATE TABLE and before the parentheses)
        tableName=$(echo $1 | grep -ioP '(?<=create table )[a-zA-Z0-9_]+(?=\s*\()')
        echo "Table Name: $tableName"

        # Extract column definitions (everything inside the parentheses after CREATE TABLE)
        columnDefs=$(echo $1 | grep -oP '(?<=\().*(?=\))')
        echo "Column Definitions: $columnDefs"

        # Extract column names, data types, and constraints
        columnNames=($(echo $columnDefs | grep -oP '^[^ ]+'))
        dataTypes=($(echo $columnDefs | grep -oP '[a-zA-Z0-9]+[ ]*[a-zA-Z0-9]*' | awk '{print $1}'))
        constraints=($(echo $columnDefs | grep -oP 'NOT NULL|PRIMARY KEY|UNIQUE'))

        echo "Column Names: ${columnNames[@]}"
        echo "Data Types: ${dataTypes[@]}"
        echo "Constraints: ${constraints[@]}"
    elif [[ $1 =~ ^[[:space:]]*[cC][lL][eE][aA][rR] ]]; then
        clear
    else
        print "Invalid query" "white" "red"
        return
    fi
    set +f
}