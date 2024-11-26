#!/usr/bin/bash

################################################################################
#
# This file contains scripts to Create Table, List Tables, Drop Table, 
# Insert into Table, Select From Table, Delete From Table, Update Table
#
################################################################################

# Load the helper functions
source ./helper.sh
source ./metadata.sh

# function that create a new Table
# $1: table name
function createTable() {
    # check if the Table name is alphanumeric
    if [[ $(isAlphaNumeric $1) -eq 0 ]]; then
        print "Table name should be alphanumeric" "white" "red"
        return
    fi

    # check if the Table already exists
    if [[ $(fileExists $1) -eq 1 ]]; then
        print "Table already exists" "white" "red"
        return
    fi

    # check if the Table name is too long
    if [[ $(isNameTooLong $1) -eq 1 ]]; then
        print "Table name is too long" "white" "red"
        return
    fi

    # check if the path is too long
    if [[ $(isPathTooLong $1) -eq 1 ]]; then
        print "Path is too long" "white" "red"
        return
    fi

    # check if we have write permission in the current directory
    if [[ $(hasWritePermission) -eq 0 ]]; then
        print "No write permission in the current directory" "white" "red"
        return
    fi

    # check if we have execute permission in the current directory
    if [[ $(hasExecutePermission) -eq 0 ]]; then
        print "No execute permission in the current directory" "white" "red"
        return
    fi

    # create the Table
    touch $1
    addTableToMetadata $1
    print "Table created successfully" "white" "green"
    
}

# function that list all the Tables
function listTables() {
    # check if we have read permission in the current directory
    if [[ $(hasReadPermission) -eq 0 ]]; then
        print "No read permission in the current directory" "white" "red"
        return
    fi

    # list all the Tables
    print "Tables:" "white" "green"
    ls -p | grep -v / | nl 
}

# function that drop a Table
function dropTable() {
        
        # check if the Table name is alphanumeric
        if [[ $(isAlphaNumeric $1) -eq 0 ]]; then 
            print "Table name should be alphanumeric" "white" "red"
            return
        fi
    
        # check if the Table exists
        if [[ $(fileExists $1) -eq 0 ]]; then
            print "Table does not exist" "white" "red"
            return
        fi
    
        # check if we have write permission in the current directory
        if [[ $(hasWritePermission) -eq 0 ]]; then
            print "No write permission in the current directory" "white" "red"
            return
        fi
    
        # check if we have execute permission in the current directory
        if [[ $(hasExecutePermission) -eq 0 ]]; then
            print "No execute permission in the current directory" "white" "red"
            return
        fi
    
        # drop the Table
        rm $1
        print "Table dropped successfully" "white" "green"
    
}

# function that insert into a Table
# $1: table name
function insertIntoTable() {
    # check if table exists
    if [[ $(fileExists $1) -eq 0 ]]; then
        print "Table does not exist" "white" "red"
        return
    fi

    # get column names
    columns=$(getColumnNames $1)
    record=""
    for column in $columns; do
        read -p "Enter $column: " value

        # get column index
        index=$(getColumnIndex $1 $column)

        # first check: if the column is primary key then it mustn't be empty and must be unique (not exist in the table)
        if [[ $(getPrimaryKey $1) -eq $column ]]; then
            # check if the value is empty
            if [[ -z $value ]]; then
                print "Primary key must not null" "white" "red"
                return
            fi
            # check if the value exists in the table
            # index will be (index/4)+1 to map between index in metadata and index in the actual table
            if [[ $(valueExists $1 $((index/4+1)) $value) -eq 1 ]]; then
                print "Primary key must be unique" "white" "red"
                return
            fi
        fi

        # second check: if the column is not null then it mustn't be empty
        if [[ $(getColumnNullConstraint $1 $column) -eq 1 ]]; then
            # check if the value is empty
            if [[ -z $value ]]; then
                print "$column must not be null" "white" "red"
                return
            fi
        fi

        # third check: if the column is unique then it must be unique (not exist in the table)
        if [[ $(getColumnUniqueConstraint $1 $column) -eq 1 ]]; then
            # check if the value exists in the table
            if [[ $(valueExists $1 $index $value) -eq 1 ]]; then
                print "$column must be unique" "white" "red"
                return
            fi
        fi

        # fourth check: check data type
        echo $(getColumnType $1 $column)
        if [[ $(getColumnType $1 $column) == "int" ]]; then
            if [[ $(isNumber $value) -eq 0 ]]; then
                print "$column must be an integer" "white" "red"
                return
            fi
        elif [[ $(getColumnType $1 $column) == "varchar" ]]; then
            if [[ $(containsColon $value) -eq 1 ]]; then
                print "$column must not contain :" "white" "red"
                return
            fi
        fi

        # fifth check: check data length
        if [[ $(getColumnSize $1 $column) -lt ${#value} ]]; then
            print "$column must not exceed $(getColumnSize $1 $column) characters" "white" "red"
            return
        fi

        # insert the value into the record
        record="$record$value:"
    done
    # remove trialing :
    record=${record%?}
    # insert the record into the table
    echo $record >> $1
}

# function that select from a Table
# function selectFromTable() {
    
# }

# # function that delete from a Table
# function deleteFromTable() {
    
# }

# # function that update a Table
# function updateTable() {
    
# }