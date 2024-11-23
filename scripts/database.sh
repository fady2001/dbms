#!/usr/bin/bash

################################################################################
#
# This file contains scripts to create, drop, connect , list database(s)
#
################################################################################

# Load the helper functions
source ./helper.sh

# function that create a new database
function createDatabase() {
    # check if the database name is alphanumeric
    if [[ $(isAlphaNumeric $1) -eq 0 ]]; then
        echo "Database name should be alphanumeric"
        return
    fi

    # check if the database already exists
    if [[ $(dirExists $1) -eq 1 ]]; then
        echo "Database already exists"
        return
    fi

    # check if the database name is too long
    if [[ $(isNameTooLong $1) -eq 1 ]]; then
        echo "Database name is too long"
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

    # create the database
    mkdir $1
    echo "Database created successfully"
}

# function that list all the databases
function listDatabases() {
    
    # check if we have read permission in the current directory
    if [[ $(hasReadPermission) -eq 0 ]]; then
        echo "No read permission in the current directory"
        return
    fi
    echo "Listing Databases"
    ls -d */ | nl | sed 's|/||'
}

# function that connect to a database
function connectToDatabase() {
    
    # check if we have read permission in the current directory
    if [[ $(hasReadPermission) -eq 0 ]]; then
        echo "No read permission in the current directory"
        return 1
    fi

    # check if we have execute permission in the current directory
    if [[ $(hasExecutePermission) -eq 0 ]]; then
        echo "No execute permission in the current directory"
        return 1
    fi

    # check if the database exists    
    if [[ $(dirExists $1) -eq 1 ]]; then
        cd $1
        echo "Connected to $1"
        return 0
    else
        echo "Database does not exist"
        return 1
    fi
}

# function that drop a database
function dropDatabase() {
    # check if we have write permission in the current directory
    if [[ $(hasWritePermission) -eq 0 ]]; then
        echo "No write permission in the current directory"
        return
    fi    

    # check if the database already exists
    if [[ $(dirExists $1) -eq 1 ]]; then
        rm -r -i $1
        echo "Database dropped successfully"
    else
        echo "Database does not exist"
        return
    fi 
}