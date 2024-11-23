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
function createTable() {
    # check if the Table name is alphanumeric
    if [[ $(isAlphaNumeric $1) -eq 0 ]]; then
        echo "Table name should be alphanumeric"
        return
    fi

    # check if the Table already exists
    if [[ $(fileExists $1) -eq 1 ]]; then
        echo "Table already exists"
        return
    fi

    # check if the Table name is too long
    if [[ $(isNameTooLong $1) -eq 1 ]]; then
        echo "Table name is too long"
        return
    fi

    # check if the path is too long
    if [[ $(isPathTooLong $1) -eq 1 ]]; then
        echo "Path is too long"
        return
    fi

    # check if we have write permission in the current directory
    if [[ $(hasWritePermission) -eq 0 ]]; then
        echo "No write permission in the current directory"
        return
    fi

    # check if we have execute permission in the current directory
    if [[ $(hasExecutePermission) -eq 0 ]]; then
        echo "No execute permission in the current directory"
        return
    fi

    # create the Table
    touch $1
    addTableToMetadata $1 $2
    echo "Table created successfully"
    
}

# function that list all the Tables
function listTables() {
    # check if we have read permission in the current directory
    if [[ $(hasReadPermission) -eq 0 ]]; then
        echo "No read permission in the current directory"
        return
    fi

    # list all the Tables
    ls -p | grep -v / | nl 
}

# function that drop a Table
function dropTable() {
        
        # check if the Table name is alphanumeric
        if [[ $(isAlphaNumeric $1) -eq 0 ]]; then
            echo "Table name should be alphanumeric"
            return
        fi
    
        # check if the Table exists
        if [[ $(fileExists $1) -eq 0 ]]; then
            echo "Table does not exist"
            return
        fi
    
        # check if we have write permission in the current directory
        if [[ $(hasWritePermission) -eq 0 ]]; then
            echo "No write permission in the current directory"
            return
        fi
    
        # check if we have execute permission in the current directory
        if [[ $(hasExecutePermission) -eq 0 ]]; then
            echo "No execute permission in the current directory"
            return
        fi
    
        # drop the Table
        rm $1
        echo "Table dropped successfully"
    
}

# function that insert into a Table
# function insertIntoTable() {
    
# }

# # function that select from a Table
# function selectFromTable() {
    
# }

# # function that delete from a Table
# function deleteFromTable() {
    
# }

# # function that update a Table
# function updateTable() {
    
# }