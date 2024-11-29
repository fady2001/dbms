#!/usr/bin/bash

################################################################################
#
# This file contains scripts to create, drop, connect , list database(s)
#
################################################################################

# function that create a new database
function createDatabase() {
    # check if the database name is alphanumeric
    if [[ $(isAlphaNumeric $1) -eq 0 ]]; then
        print "Error: Database name should be alphanumeric" "white" "red"
        return
    fi

    # check if the database already exists
    if [[ $(dirExists $1) -eq 1 ]]; then
        print "Error: Database already exists" "white" "red"
        return
    fi

    # check if the database name is too long
    if [[ $(isNameTooLong $1) -eq 1 ]]; then
        print "Error: Database name is too long" "white" "red"
        return
    fi

    # check if the path is too long
    if [[ $(isPathTooLong $1) -eq 1 ]]; then
        print "Error: Path is too long" "white" "red"
        return
    fi

    # check if we have write permission in the current directory
    if [[ $(hasWritePermission) -eq 0 ]]; then
        print "Error: No write permission in the current directory" "white" "red"
        return
    fi

    # check if we have execute permission in the current directory
    if [[ $(hasExecutePermission) -eq 0 ]]; then
        print "Error: No execute permission in the current directory" "white" "red"
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
        print "Error: No read permission in the current directory" "white" "red"
        return
    fi

    # check if there are no databases
    if [[ $(find . -maxdepth 1 -type d ! -name '.' ! -name '.vscode' | wc -l) -eq 0 ]]; then
        print "Error: No databases found" "white" "red"
    else
        print "Listing Databases successfully" "white" "green"
        ls -d */ | nl | sed 's|/||'
    fi
}

# function that connect to a database
function connectToDatabase() {
    
    # check if we have read permission in the current directory
    if [[ $(hasReadPermission) -eq 0 ]]; then
        print "Error: No read permission in the current directory" "white" "red"
        return 1
    fi

    # check if we have execute permission in the current directory
    if [[ $(hasExecutePermission) -eq 0 ]]; then
        print "Error: No execute permission in the current directory" "white" "red"
        return 1
    fi

    # check if the database exists    
    if [[ $(dirExists $1) -eq 1 ]]; then
        cd $1
        CURRENT_DB_PATH=$PWD
        CURRENT_DB_NAME=$1
        print "Connected to $1 successfully" "white" "green"
        return 0
    else
        print "Error: Database does not exist" "white" "red"
        return 1
    fi
}

# function that drop a database
function dropDatabase() {
    # check if we have write permission in the current directory
    if [[ $(hasWritePermission) -eq 0 ]]; then
        print "Error: No write permission in the current directory" "white" "red"
        return
    fi

    # check if the database already exists
    if [[ $(dirExists $1) -eq 1 ]]; then
        # use zenity to ask the user if he is sure to delete the database
        zenity --question --title="Confirmation" --text="Are you sure you want to delete the database $1?"
        if [[ $? -eq 0 ]]; then
            rm -r $1
        else
            return
        fi
        print "Database dropped successfully" "white" "green"
    else 
        print "Error: Database does not exist" "white" "red"
        return
    fi
}