#!/usr/bin/bash
################################################################################
#
# This file contains scripts to deal with tables using sql commands
#
################################################################################

# function that takes a table name and columns' names, data types , sizes and constraints
# add information about the table to the metadata file and create table file
# $1: table name
# $2: columns' names
# $3: columns' data types
# $4: columns' sizes
# $5: columns' constraints
function sqlcreateTable() {
    # create reference for arrays
    local -n col_names=$2
    local -n col_types=$3
    local -n col_sizes=$4
    local -n col_constraints=$5
    # check if meta data file exists
    if [[ ! -f $CURRENT_DB_PATH/.$CURRENT_DB_NAME ]]; then
        print "Error: No database is connected" "white" "red"
        return
    fi
    # check that number of elements in columns' names, data types, sizes and constraints are equal
    if [[ ${#col_names[@]} -ne ${#col_types[@]} || ${#col_names[@]} -ne ${#col_sizes[@]} || ${#col_names[@]} -ne ${#col_constraints[@]} ]]; then
        print "Error: An error in parsing columns" "white" "red"
        return
    fi

    # check if the table name is empty (indicator of parsing problem)
    if [[ -z $1 ]]; then
        print "Error: an error in parsing table name" "white" "red"
        return
    fi
    
    # check if the table already exists
    if [[ $(fileExists $1) -eq 1 ]]; then
        print "Error: Table already exists" "white" "red"
        return
    fi

    # check if the table name is too long
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

    # create the table
    touch $1
    # create metadata file for the table
    tableMetadata="$1:"
    for (( i=0; i<${#col_names[@]}; i++ )); do
        tableMetadata+="${col_names[$i]}:${col_types[$i]}:${col_sizes[$i]}:${col_constraints[$i]}:"
    done
    # remove trailing colon
    tableMetadata=${tableMetadata%?}
    echo $tableMetadata >> $CURRENT_DB_PATH/.$CURRENT_DB_NAME
    print "Table created successfully" "white" "green"
}

# function that takes table name and values to insert into the table
# insert the values into the table
# $1: table name
# $2: column names
# $3: values to insert
function sqlinsertIntoTable() {
    # check if table exists
    if [[ $(fileExists $1) -eq 0 ]]; then
        print "Error: Table does not exist" "white" "red"
        return
    fi

    local -n cols=$2
    local -n vals=$3

    # get column names
    record=""
    for (( i=0; i<${#cols[@]}; i++ )); do
    value=$(echo ${vals[$i]} | tr -d "'")

    # check if the value follows the constraints
    if [[ $(followConstraints $1 ${cols[$i]} $value) -eq 0 ]]; then
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
    print "Record inserted successfully" "white" "green"
}

# function that update a Table
# $1: table name
# $2: columns to update
# $3: new values
# $4: conditions
function sqlUpdateTable() {
    local -n cols=$2
    local -n vals=$3
    conds=$4

    # check if table exists
    if [[ $(fileExists $1) -eq 0 ]]; then
        print "Error: Table does not exist" "white" "red"
        return
    fi

    # get column indecies in table file
    declare -a indecies
    for col in ${cols[@]}; do
        # get column index
        index=$(getColumnIndex $1 $col)
        # check if the column exists
        if [[ $index -eq -1 ]]; then
            print "Error: Column $col does not exist in the table" "white" "red"
            return
        else
            # actual index in the table file equals (index/4)+1
            indecies+=($((index/4+1)))
        fi
    done

    # check if values length is larger than columns length
    if [[ ${#vals[@]} -ne ${#cols[@]} ]]; then
        print "Error: Number of values is not equal to number of columns" "white" "red"
        return
    fi

    for i in ${!cols[@]}; do
        # check if the value follows the constraints
        if [[ $(followConstraints $1 ${cols[$i]} ${vals[$i]}) -eq 0 ]]; then
            return
        fi
    done

    # create a temporary hidden file to store the updated table to back up the original table
    touch .temp
    cp $1 .temp

    # loop over the table file
    while IFS= read -r line; do
        eval_cond=$(evaluateConditions $1 "$line" "$conds")
        if [[ $eval_cond -eq 1 ]]; then
            # split the line by delimiter
            IFS=':' read -r -a fields <<< $line
            for i in ${indecies[@]}; do
                # values idx starts from 0
                idx=$((0))
                # update the field
                fields[$i-1]=${vals[$idx]}
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
    if [[ $(satisfyConstraints $1 $cols) -eq 0 ]]; then
        # restore the original table
        mv .temp $1
    else
        # remove the temporary file
        rm .temp
        print "Table updated successfully" "white" "green"
    fi
}

# function that delete from a Table
# $1: table name
# $2: conditions
function sqlDeleteFromTable() {
    conds=$2
    # check if table exists
    if [[ $(fileExists $1) -eq 0 ]]; then
        print "Error: Table does not exist" "white" "red"
        return
    fi

    # loop over the table file
    while IFS= read -r line; do
        eval_cond=$(evaluateConditions $1 "$line" "$conds")
        if [[ $eval_cond -eq 1 ]]; then
            # delete the line from the table file
            sed -i "/$line/d" $1
        elif [[ $eval_cond -eq -1 ]]; then
            print "Invalid operator" "white" "red"
            return
        fi
    done < $1
    print "Record deleted successfully" "white" "green"
}

# function that select from a Table
# $1: table name
# $2: columns to select
# $3: conditions
function sqlSelectFromTable() {
    local -n cols=$2
    conds=$3
    # check if table exists
    if [[ $(fileExists $1) -eq 0 ]]; then
        print "Error: Table doese not exist" "white" "red"
        return
    fi

    if [[ ${cols[0]} == "*" ]]; then
        # set columns array to all columns in the table
        IFS=' ' read -r -a cols <<< "$(getColumnNames $1)"    
    fi
    # get column indecies in table file
    declare -a indecies
    for col in ${cols[@]}; do
        # get column index
        index=$(getColumnIndex $1 $col)
        # check if the column exists
        if [[ $index -eq -1 ]]; then
            print "Error: Column $col does not exist in the table" "white" "red"
            return
        else
            # actual index in the table file equals (index/4)+1
            indecies+=($((index/4+1)))
        fi
    done

    output=""
    for column in ${cols[@]}; do
        output="$output$column\t"
    done
    # remove trailing tab
    output=${output%?}
    # add a new line
    output="$output"\n

    # loop over the table file
    while IFS= read -r line; do
        eval_cond=$(evaluateConditions $1 "$line" "$conds")
        if [[ $eval_cond -eq 1 ]]; then
            # split the line by delimiter
            IFS=':' read -r -a fields <<< $line
            for i in ${indecies[@]}; do
                output="$output${fields[$i-1]}\t"
            done
            # remove trailing tab
            output=${output%?}
            output="$output"\n
        elif [[ $eval_cond -eq -1 ]]; then
            print "Invalid operator" "white" "red"
            return
        fi
    done < $1
    echo -e $output
}