#!/usr/bin/bash

################################################################################
#
# This file contains scripts to Create Table, List Tables, Drop Table, 
# Insert into Table, Select From Table, Delete From Table, Update Table
#
################################################################################

# export CURRENT_DB_PATH="$PWD/iti"
# export CURRENT_DB_NAME="iti"

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

        # check if the value follows the constraints
        if [[ $(followConstraints $1 $column $value) -eq 0 ]]; then
            return
        else
            # insert the value into the record
            record="$record$value:"
        fi

    done
    # remove trialing :
    record=${record%?}
    # insert the record into the table
    echo $record >> $1
}

# function that update a Table
# $1: table name
function updateTable() {
    # check if table exists
    if [[ $(fileExists $1) -eq 0 ]]; then
        print "Table does not exist" "white" "red"
        return
    fi

    declare -a columns
    declare -a values

    # get column names that user wants to update separated by comma
    IFS=','
    read -p "Enter the columns you want to update separated by comma: " -a columns
    # get values for the columns separated by comma
    IFS=','
    read -p "Enter the values you want to update separated by comma: " -a values
    # get conditions
    read -p "Enter the conditions separated by comma: " conditions

    # declare hard coded values for testing
    # columns=("id")
    # values=(23)
    # conditions="id=3"

    # get column indecies in table file
    declare -a indecies
    for column in ${columns[@]}; do
        # trim leading and trailing whitespaces
        column=$(echo $column | tr -d ' ')
        # get column index
        index=$(getColumnIndex $1 $column)
        # check if the column exists
        if [[ $index -eq -1 ]]; then
            print "Column $column does not exist in the table" "white" "red"
            return
        else
            # actual index in the table file equals (index/4)+1
            indecies+=($((index/4+1)))
        fi
    done

    # check if values length is larger than columns length
    if [[ ${#values[@]} -ne ${#columns[@]} ]]; then
        print "Number of values is not equal to number of columns" "white" "red"
        return
    fi

    for i in ${!columns[@]}; do
        # check if the value follows the constraints
        if [[ $(followConstraints $1 ${columns[$i]} ${values[$i]}) -eq 0 ]]; then
            return
        fi
    done

    # create a temporary hidden file to store the updated table to back up the original table
    touch .temp
    cp $1 .temp

    # loop over the table file
    while IFS= read -r line; do
        eval_cond=$(evaluateConditions $1 $line $conditions)
        if [[ $eval_cond -eq 1 ]]; then
            # split the line by delimiter
            IFS=':' read -r -a fields <<< $line
            for i in ${indecies[@]}; do
                fields[$i-1]=${values[$i-1]}
            done
            # update the line
            new_line=""
            for field in ${fields[@]}; do
                new_line="$new_line$field:"
            done
            # remove trialing :
            new_line=${new_line%?}
            # update the line in the table file
            sed -i "s/$line/$new_line/" $1
        elif [[ $eval_cond -eq -1 ]]; then
            print "Invalid operator" "white" "red"
            return
        fi
    done < $1
    # check if constraints are violated after updating
    if [[ $(satisfyConstraints $1 $columns) -eq 0 ]]; then
        # restore the original table
        mv .temp $1
    else
        # remove the temporary file
        rm .temp
        print "Table updated successfully" "white" "green"
    fi
}

# function that select from a Table
# function selectFromTable() {
    
# }

# # function that delete from a Table
# function deleteFromTable() {
    
# }