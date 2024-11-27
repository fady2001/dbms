#!/usr/bin/bash

################################################################################
#
# This file contains scripts to create, drop, connect , list database(s)
#
################################################################################

# Load the helper functions
source ./helper.sh
source ./metadata.sh

# function that create a new database
function createDatabase() {
    # check if the database name is alphanumeric
    if [[ $(isAlphaNumeric $1) -eq 0 ]]; then
        print "Database name should be alphanumeric" "white" "red"
        return
    fi

    # check if the database already exists
    if [[ $(dirExists $1) -eq 1 ]]; then
        print "Database already exists" "white" "red"
        return
    fi

    # check if the database name is too long
    if [[ $(isNameTooLong $1) -eq 1 ]]; then
        print "Database name is too long" "white" "red"
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

    # create the database
    mkdir $1
    # create metadata file for the database
    createMetadataFile $1
    print "Database created successfully" "white" "green"
}

# function that list all the databases
function listDatabases() {

    # check if we have read permission in the current directory
    if [[ $(hasReadPermission) -eq 0 ]]; then
        print "No read permission in the current directory" "white" "red"
        return
    fi

    # check if there are no databases
    if [[ $(find . -maxdepth 1 -type d ! -name . | wc -l) -eq 0 ]]; then
        print "No databases found" "white" "red"
        return
    else
        print "Listing Databases" "white" "green"
        ls -d */ | nl | sed 's|/||'
    fi
}

# function that connect to a database
function connectToDatabase() {
    
    # check if we have read permission in the current directory
    if [[ $(hasReadPermission) -eq 0 ]]; then
        print "No read permission in the current directory" "white" "red"
        return 1
    fi

    # check if we have execute permission in the current directory
    if [[ $(hasExecutePermission) -eq 0 ]]; then
        print "No execute permission in the current directory" "white" "red"
        return 1
    fi

    # check if the database exists    
    if [[ $(dirExists $1) -eq 1 ]]; then
        cd $1
        print "Connected to $1" "white" "green"
        return 0
    else
        print "Database does not exist" "white" "red"
        return 1
    fi
}

# function that drop a database
function dropDatabase() {
    # check if we have write permission in the current directory
    if [[ $(hasWritePermission) -eq 0 ]]; then
        print "No write permission in the current directory" "white" "red"
        return
    fi

    # check if the database already exists
    if [[ $(dirExists $1) -eq 1 ]]; then
        rm -r -i $1
        print "Database dropped successfully" "white" "green"
    else 
        print "Database does not exist" "white" "red"
        return
    fi
}