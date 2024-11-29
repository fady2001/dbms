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
# source ./helper.sh
# source ./metadata.sh

# function that create a new Table
# $1: table name
function createTable() {
    # check if the Table name is alphanumeric
    if [[ $(isAlphaNumeric $1) -eq 0 ]]; then
        print "Error: Table name should be alphanumeric" "white" "red"
        return
    fi

    # check if the Table already exists
    if [[ $(fileExists $1) -eq 1 ]]; then
        print "Error: Table already exists" "white" "red"
        return
    fi

    # check if the Table name is too long
    if [[ $(isNameTooLong $1) -eq 1 ]]; then
        print "Error: Table name is too long" "white" "red"
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

    # create the Table
    touch $1
    addTableToMetadata $1
    print "Table created successfully" "white" "green"
    
}

# function that list all the Tables
function listTables() {
    # check if we have read permission in the current directory
    if [[ $(hasReadPermission) -eq 0 ]]; then
        print "Error: No read permission in the current directory" "white" "red"
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
            print "Error: Table name should be alphanumeric" "white" "red"
            return
        fi
    
        # check if the Table exists
        if [[ $(fileExists $1) -eq 0 ]]; then
            print "Error: Table does not exist" "white" "red"
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
    
        # drop the Table
        rm $1
        dropTableFromMetadata $1
        print "Table dropped successfully" "white" "green"
    
}

# function that insert into a Table
# $1: table name
function insertIntoTable() {
    # check if table exists
    if [[ $(fileExists $1) -eq 0 ]]; then
        print "Error: Table does not exist" "white" "red"
        return
    fi

    # get column names
    columns=$(getColumnNames $1)
    record=""
    for column in $columns; do
        read -p "Enter $column: " value
        # remove qoutes if exists
        value=$(echo $value | tr -d "'")
        if [[ -z $value ]]; then
            value="null"
        fi

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
        print "Error: Table does not exist" "white" "red"
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
    read -p "Enter the conditions like sql (age=30 and/or id=10): " conditions

    # declare hard coded values for testing
    # columns=("name")
    # values=(fady)
    # conditions="id=23"

    # remove leading and trailing whitespaces
    for i in ${!columns[@]}; do
        columns[$i]=$(echo ${columns[$i]} | xargs)
    done
    for i in ${!values[@]}; do
        values[$i]=$(echo ${values[$i]} | xargs)
    done
    

    # get column indecies in table file
    declare -a indecies
    for column in ${columns[@]}; do
        # echo "Column: $column"
        # get column index
        index=$(getColumnIndex $1 $column)
        # check if the column exists
        if [[ $index -eq -1 ]]; then
            print "Error: Column $column does not exist in the table" "white" "red"
            return
        else
            # actual index in the table file equals (index/4)+1
            indecies+=($((index/4+1)))
        fi
    done

    # check if values length is larger than columns length
    if [[ ${#values[@]} -ne ${#columns[@]} ]]; then
        print "Error: Number of values is not equal to number of columns" "white" "red"
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
        eval_cond=$(evaluateConditions $1 $line "$conditions")
        if [[ $eval_cond -eq 1 ]]; then
            # split the line by delimiter
            IFS=':' read -r -a fields <<< $line
            for i in ${indecies[@]}; do
                # values idx starts from 0
                idx=$((0))
                # update the field
                fields[$i-1]=${values[$idx]}
                # increment the values idx
                idx=$((idx+1))
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
            print "Error: Invalid operator" "white" "red"
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

# updateTable emp


# function that select from a Table
# $1: table name
function selectFromTable() {
    set -f
    # check if table exists
    if [[ $(fileExists $1) -eq 0 ]]; then
        print "Error: Table does not exist" "white" "red"
        return
    fi

    declare -a columns

    # get column names that user wants to select from separated by comma
    IFS=','
    read -p "Enter the columns you want to select separated by comma: " -a columns
    # get conditions
    read -p "Enter the conditions like sql (age=30 and/or id=10): " conditions
    
    if [[ -z $columns ]]; then
        print "Error: Columns cannot be empty" "white" "red"
        return
    fi

    # check if columns is *
    if [[ ${columns[0]} == "*" ]]; then
        # set columns array to all columns in the table
        IFS=' ' read -r -a columns <<< "$(getColumnNames $1)"    
    fi
    set +f
    # remove leading and trailing whitespaces
    for i in ${!columns[@]}; do
        columns[$i]=$(echo ${columns[$i]} | tr -d ' ')
    done

    # get column indecies in table file
    declare -a indecies
    for column in ${columns[@]}; do
        # get column index
        index=$(getColumnIndex $1 $column)
        # check if the column exists
        if [[ $index -eq -1 ]]; then
            print "Error: Column $column does not exist in the table" "white" "red"
            return
        else
            # actual index in the table file equals (index/4)+1
            indecies+=($((index/4+1)))
        fi
    done

    # create a variable to store the selected columns names separated by tab to print them
    output=""
    for column in ${columns[@]}; do
        output="$output$column\t"
    done
    # remove trailing tab
    output=${output%?}
    # add a new line
    output="$output"\n

    # loop over the table file
    while IFS= read -r line; do
        eval_cond=$(evaluateConditions $1 $line $conditions)
        if [[ $eval_cond -eq 1 ]]; then
            # print the selected columns names and values separated by tab
            IFS=':' read -r -a fields <<< $line
            # append the selected columns values to the output variable
            for i in ${indecies[@]}; do
                output="$output${fields[$i-1]}\t"
            done
            # remove trailing tab
            output=${output%?}
            output="$output"\n
        elif [[ $eval_cond -eq -1 ]]; then
            print "Error: Invalid operator" "white" "red"
            return
        fi
    done < $1
    echo -e $output
}


# # function that delete from a Table
#$1: table name
function deleteFromTable() {
    # check if table exists
    if [[ $(fileExists $1) -eq 0 ]]; then
        print "Error: Table does not exist" "white" "red"
        return
    fi

    # get conditions
    read -p "Enter the conditions like sql (age=30 and/or id=10): " conditions


    # loop over the table file
    while IFS= read -r line; do
        eval_cond=$(evaluateConditions $1 $line $conditions)
        if [[ $eval_cond -eq 1 ]]; then
            # delete the line from the table file
            sed -i "/$line/d" $1
        elif [[ $eval_cond -eq -1 ]]; then
            print "Error: Invalid operator" "white" "red"
            return
        fi
    done < $1
    print "Records deleted successfully" "white" "green"
}

# function to alter table (add new column)
# $1: table name
# $2: column name
# $3: data type
# $4: data length
# $5: constraints (yyy,nyy,ynn ..etc)
# $6: default value
function alterTableAddColumn() {
    # add the column to the table
    # function to add a column to the metadata
    if [[ $(addColumnToMetadata $1 $2 $3 $4 $5) -eq -1 ]]; then
        echo -1
        return
    fi
    # add the column to the table file
    awk '
        BEGIN { IFS=":"; OFS=":" } 
        { print $0, def }
    ' "$1" > "$1"
    echo 1
    print "Column added successfully" "white" "green"
}


alterTable() {
    local tableName=$1
    if [[ -z $tableName ]]; then
        print "Table name cannot be empty." "white" "red"
        return 1
    fi

    if [[ ! -f "$CURRENT_DB_PATH/$tableName" ]]; then
        print "Table '$tableName' does not exist." "white" "red"
        return 1
    fi
    clear
    while true; do
        echo "Select an option to alter the $tableName table:"
        select option in "Add Column" "Drop Column" "Rename Column" "Change Data Type" "Change Data Length" "Add Constraint" "Remove Constraint" "Exit"; do
            case $option in
                "Add Column")
                    read -p "Enter the column name: " columnName
                    # check if the column name is alphanumeric
                    if [[ $(isAlphaNumeric $columnName) -eq 0 ]]; then
                        print "Error: Column name should be alphanumeric" "white" "red"
                        break
                    fi

                    # check if the column already exists
                    if [[ $(getColumnIndex $tableName $columnName) -ne -1 ]]; then
                        print "Error: Column already exists" "white" "red"
                        break
                    fi
                    
                    read -p "Enter the column type: " columnType
                    if [[ ! $columnType =~ ^([iI][nN][tT]|[vV][aA][rR][cC][hH][aA][rR])$ ]]; then
                        print "Error: type is not supported" "white" "red"
                        break
                    fi
                    
                    read -p "Enter the column length: " columnLength
                    if [[ $(isNumber $columnLength) -eq 0 || $columnLength -eq 0 || $columnLength =~ ^- ]]; then
                        print "Error: unvalid column length" "white" "red"
                        break
                    fi
                    
                    read -p "Enter the column constraint primary key or not null or unique: " columnConstraint
                    # handling the constraints
                    constraint=""
                    # handling primary key constraint
                    if [[ $columnConstraint =~ [pP][rR][iI][mM][aA][rR][yY] ]]; then
                        constraint+='y'
                    else
                        constraint+='n'
                    fi
                    # handling not null constraint
                    if [[ $columnConstraint =~ [nN][oO][tT][[:space:]]+[nN][uU][lL][lL] ]]; then 
                        constraint+='y'
                    else
                        constraint+='n'
                    fi
                    # handling unique constraint
                    if [[ $columnConstraint =~ [uU][nN][iI][qQ][uU][eE] ]]; then
                        constraint+='y'
                    else
                        constraint+='n'
                    fi
                    pk=$(getPrimaryKey $tableName)
                    if [[ $pk -ne -1 && ${5:0:1} == "y" ]]; then
                        print "Error: column $pk is the primary key for $tableName table" "white" "red"
                        break
                    fi
                    
                    read -p "Enter default value if exist: " default
                    if [[ ${5:1:1} == "y" && -z $default ]]; then
                        print "Error: need a default value" "white" "red"
                        break
                    fi

                    if [[ ${5:2:1} == "y" && ! -z $default ]]; then
                        print "warning: Unique column cannot have default value" "white" "yellow"
                        default=""
                    fi

                    if [[ ! -z $default && $(isNumber $default) -eq 0 && $columnType =~ ^([iI][nN][tT])$ ]];then
                        print "Error: default value and column don't have the same type" "white" "red"
                        break
                    fi

                    if [[ $(alterTableAddColumn $tableName $columnName $columnType $columnLength $constraint $default) -eq -1 ]]; then
                        break
                    fi
                    ;;
                "Drop Column")
                    read -p "Enter the column name: " columnName
                    # check if the column name is alphanumeric
                    if [[ $(isAlphaNumeric $columnName) -eq 0 ]]; then
                        print "Error: Column name should be alphanumeric" "white" "red"
                        break
                    fi

                    # check if the column already exists
                    if [[ ! $(getColumnIndex $tableName $columnName) -ne -1 ]]; then
                        print "Error: Column doesn't exist" "white" "red"
                        break
                    fi

                    if [[ $(deleteColumnFromMetadata $tableName $columnName) -eq -1 ]]; then
                        break
                    fi
                    print "Dropping column '$columnName' from table '$tableName'."
                    # Example: sed -i "/$columnName/d" "$CURRENT_DB_PATH/$tableName"
                    ;;
                "Rename Column")
                    read -p "Enter the current column name: " currentColumnName
                    # check if the column name is alphanumeric
                    if [[ $(isAlphaNumeric $currentColumnName) -eq 0 ]]; then
                        print "Error: currentColumnName name should be alphanumeric" "white" "red"
                        break
                    fi

                    # check if the column already exists
                    if [[ ! $(getColumnIndex $tableName $currentColumnName) -ne -1 ]]; then
                        print "Error: Column doesn't exist" "white" "red"
                        break
                    fi
                    read -p "Enter the new column name: " newColumnName
                    if [[ $(isAlphaNumeric $newColumnName) -eq 0 ]]; then
                        print "Error: newColumnName name should be alphanumeric" "white" "red"
                        break
                    fi
                    # Add logic to rename the column in the table
                    renameColumn $tableName $currentColumnName $newColumnName
                    ;;
                "Change Data Type")
                    read -p "Enter the column name: " columnName
                    # check if the column name is alphanumeric
                    if [[ $(isAlphaNumeric $columnName) -eq 0 ]]; then
                        print "Error: Column name should be alphanumeric" "white" "red"
                        break
                    fi

                    # check if the column already exists
                    if [[ ! $(getColumnIndex $tableName $columnName) -ne -1 ]]; then
                        print "Error: Column doesn't exist" "white" "red"
                        break
                    fi
                    
                    read -p "Enter the new data type: " newDataType
                    if [[ $(isStringColumn $tableName $columnName) -eq 0 && $newDataType =~ ^([iI][nN][tT])$ ]]; then
                        print "Error: column $columnName is a string column" "white" "red"
                        break
                    fi
                    # Add logic to change the data type of the column
                    modifyColumnType $tableName $columnName $newDataType
                    ;;
                "Change Data Length")
                    read -p "Enter the column name: " columnName
                    # check if the column name is alphanumeric
                    if [[ $(isAlphaNumeric $columnName) -eq 0 ]]; then
                        print "Error: Column name should be alphanumeric" "white" "red"
                        break
                    fi

                    # check if the column already exists
                    if [[ ! $(getColumnIndex $tableName $columnName) -ne -1 ]]; then
                        print "Error: Column doesn't exist" "white" "red"
                        break
                    fi
                    
                    read -p "Enter the column length: " columnLength
                    if [[ $(isNumber $columnLength) -eq 0 || $columnLength -eq 0 || $columnLength =~ ^- ]]; then
                        print "Error: unvalid column length" "white" "red"
                        break
                    fi
                    if [[ $(isLengthLessThanData $tableName $columnName $columnLength) -eq 0 ]]; then
                        print "Error: column length is less than the data" "white" "red"
                        break
                    fi
                    
                    modifyColumnSize $tableName $columnName $columnLength
                    ;;
                "Add Constraint")
                    read -p "Enter the column name: " columnName
                    if [[ $(isAlphaNumeric $columnName) -eq 0 ]]; then
                        print "Error: Column name should be alphanumeric" "white" "red"
                        break
                    fi
                    read -p "Enter a constraint primary key or not null or unique: " columnConstraint
                    # handling primary key constraint
                    if [[ $columnConstraint =~ [pP][rR][iI][mM][aA][rR][yY] ]]; then
                        pk=$(getPrimaryKey $tableName)
                        if [[ $pk -ne -1  ]]; then
                            print "Error: column $pk is the primary key for $tableName table" "white" "red"
                            break
                        fi
                        $(modifyColumnConstraint $tableName $columnName "pk" "y")
                    fi
                    # handling not null constraint
                    if [[ $columnConstraint =~ [nN][oO][tT][[:space:]]+[nN][uU][lL][lL] ]]; then 
                        $(modifyColumnConstraint $tableName $columnName "null" "y")
                    fi
                    # handling unique constraint
                    if [[ $columnConstraint =~ [uU][nN][iI][qQ][uU][eE] ]]; then
                        $(modifyColumnConstraint $tableName $columnName "unique" "y")
                    fi
                    ;;
                "Remove Constraint")
                    read -p "remove the column constraint primary key or not null or unique: " columnConstraint
                    # handling primary key constraint
                    if [[ $columnConstraint =~ [pP][rR][iI][mM][aA][rR][yY] ]]; then
                        $(modifyColumnConstraint $tableName $columnName "pk" "n")
                    fi
                    # handling not null constraint
                    if [[ $columnConstraint =~ [nN][oO][tT][[:space:]]+[nN][uU][lL][lL] ]]; then 
                        $(modifyColumnConstraint $tableName $columnName "null" "n")
                    fi
                    # handling unique constraint
                    if [[ $columnConstraint =~ [uU][nN][iI][qQ][uU][eE] ]]; then
                        $(modifyColumnConstraint $tableName $columnName "unique" "n")
                    fi
                    ;;
                "Exit")
                    print "Are you sure you want to exit? (y/n)" "black" "yellow"
                    read -n 1 -r -s -p "" REPLY
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        return
                    fi
                    ;;
                *)
                    echo "Invalid option."
                    ;;
            esac
        done
        read -n 1 -s -r -p "Press any key to continue . . ."
        clear
    done
}
