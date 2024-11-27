#!/usr/bin/bash

################################################################################
#
# This file contains script to parse sql queries
#
################################################################################

# Load the helper functions
source ./helper.sh
source ./metadata.sh

# function that parse the sql query
# $1: sql query
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
        echo "Create database query"
        dbName=$(echo $1 | grep -ioP '(?<=database )[^ ]+(?=[$;])')
        echo $dbName
        return
    elif [[ $1 =~ ^[[:space:]]*[dD][rR][oO][pP][[:space:]]+[dD][aA][tT][aA][bB][aA][sS][eE] ]]; then
        echo "Drop database query"
        dbName=$(echo $1 | grep -ioP '(?<=database )[^ ]+(?=[$;])')
        echo $dbName
        return
    ###############################################################
    #                     Tables queries                          #
    ###############################################################
    elif [[ $1 =~ ^[[:space:]]*[sS][eE][lL][eE][cC][tT] ]]; then
        columns=$(echo $1 | grep -ioP '(?<=select ).*(?= from)')
        table=$(echo $1 | grep -ioP '(?<=from )[^ ]+(?= where|$)')
        conditions=$(echo $1 | grep -ioP '(?<=where ).*(?=[$;])')
        echo $columns
        echo $table
        echo $conditions
    elif [[ $1 =~ ^[[:space:]]*[dD][eE][lL][eE][tT][eE] ]]; then
        table=$(echo $1 | grep -ioP '(?<=from )[^ ]+(?= where|$)')
        conditions=$(echo $1 | grep -ioP '(?<=where ).*(?=[$;])')
        echo $table
        echo $conditions
        return
    elif [[ $1 =~ ^[[:space:]]*[uU][pP][dD][aA][tT][eE] ]]; then
        echo "Update query"
        table=$(echo $1 | grep -ioP '(?<=update )[^ ]+(?= set)')
        set=$(echo $1 | grep -ioP '(?<=set ).*(?= where)')
        conditions=$(echo $1 | grep -ioP '(?<=where ).*(?=[$;])')
        echo $table
        echo $set
        echo $conditions
        return
    elif [[ $1 =~ ^[[:space:]]*[iI][nN][sS][eE][rR][tT] ]]; then
        echo "Insert query"
        table=$(echo $1 | grep -ioP '(?<=into )[^ ]+(?= \(| values)')
        columns=$(echo $1 | grep -ioP '(?<=\().*(?=\) values)')
        values=$(echo $1 | grep -ioP '(?<=values \().*(?=\))')
        echo $table
        echo $values
        return
    elif [[ $1 =~ ^[[:space:]]*[dD][rR][oO][pP][[:space:]]+[tT][aA][bB][lL][eE] ]]; then
        echo "Drop query"
        table=$(echo $1 | grep -ioP '(?<=table )[^ ]+(?=[$;])')
        echo $table
        return
    elif [[ $1 =~ ^[[:space:]]*[cC][rR][eE][aA][tT][eE][[:space:]]+[tT][aA][bB][lL][eE] ]]; then
        echo "Create table query"
        
        # Extract the table name (after CREATE TABLE and before the parentheses)
        tableName=$(echo $1 | grep -ioP '(?<=create table )[^ ]+(?=\s*\()')
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
    else
        print "Invalid query" "white" "red"
        return
    fi
    set +f
}

parseQuery "

create table students (
    id int ,
    name varchar(20),
    age int
);

"