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
        dropTableFromMetadata $1
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
    read -p "Enter the conditions like sql (age=30 and/or id=10): " conditions

    # declare hard coded values for testing
    # columns=("name")
    # values=(fady)
    # conditions="id=23"

    # remove leading and trailing whitespaces
    for i in ${!columns[@]}; do
        columns[$i]=$(echo ${columns[$i]} | tr -d ' ')
    done
    for i in ${!values[@]}; do
        values[$i]=$(echo ${values[$i]} | tr -d ' ')
    done
    

    # get column indecies in table file
    declare -a indecies
    for column in ${columns[@]}; do
        echo "Column: $column"
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
            echo "New line: $new_line" 
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

# updateTable emp


# function that select from a Table
 function selectFromTable() {
    # check if table exists
    if [[ $(fileExists $1) -eq 0 ]]; then
        print "Table does not exist" "white" "red"
        return
    fi
    read -p "Enter The Columns You Would Like To Select Seperated by , (* for all): " -a columns
    read -p "Enter Condition (e.g., age=35): " condition
    # Columns
    # Set the field separator to a comma
    IFS=','
    i=0
    set -f
    # Loop through each column name
    declare -a indecies
    if [[ $columns != "*" ]]; then
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
    fi
    # Reset IFS to default
    unset IFS
    
    indecies=$(IFS=,; echo "${indecies[*]}") # Join values with a comma
    
    # Extracting 
    # Extract the column name (everything before the first operator)
    column_wh=$(echo "$condition" | grep -oE '^[a-zA-Z_][a-zA-Z0-9_]*')

    # Extract the operator 
    op=$(echo "$condition" | grep -oE '(!=|<=|>=|=|<|>)')

    # Extract the value (everything after the operator)
    val=$(echo "$condition" | sed -E "s/^[a-zA-Z_][a-zA-Z0-9_]*${op}//")

    if [[ $op == "=" ]]; then
    	op="=="
    fi
    # If there was a column select then we sent it to the fucntion to get it's index
    # if not then we make it equal to "" 
    if [[ ($column_wh == "") ]] ; then

	if [[ $columns == "*" ]]; then
    		sed -n 'p' $1

    	else 
    		awk -v ind="$indecies" 'BEGIN {FS=":"; split(ind, arr, "," );} {for (i in arr)
    		{ printf "%s ",  $arr[i]} }' $1
    	fi
    else
    	temp=$(getColumnIndex $1 $column_wh);
    	column_wh=$((temp/4+1));
    	if [[ $columns == "*" ]]; then
    		if [[ $'$column_wh$op$val' ]]; then
	    		NR=($(awk 'BEGIN{FS=":"}{if ($'$column_wh$op$val')print NR}' $1))
	    		if [[ $NR != "" ]] ; then
	    			f="${NR[0]}"
				l="${NR[-1]}"
		    		sed -n "${f},${l}p" $1
		    	fi
		fi
	else 
		if [[ $'$column_wh$op$val' ]]; then
	    		awk -v ind="$indecies" 'BEGIN{FS=":"; split(ind, arr, "," );} {
	    		if ($'$column_wh$op$val'){
	    		for (i in arr){ 
	    		printf "%s ",  $arr[i]} 
	    		}
	    		}' $1
		fi
	fi
    fi
    set +f
    
 }


# # function that delete from a Table
 function deleteFromTable() {
    
    #read -p "Enter the Table name: "  table_name
    read -p "Enter Condition (e.g., age=35): " condition

    # Extracting
    # Extract the column name (everything before the first operator)
    column_wh=$(echo "$condition" | grep -oE '^[a-zA-Z_][a-zA-Z0-9_]*')

    # Extract the operator 
    op=$(echo "$condition" | grep -oE '(!=|<=|>=|=|<|>)')

    # Extract the value (everything after the operator)
    val=$(echo "$condition" | sed -E "s/^[a-zA-Z_][a-zA-Z0-9_]*${op}//")
    if [[ $op == "=" ]]; then
    	op="=="
    fi
    # If there was a column select then we sent it to the fucntion to get it's index
    # if not then we make it equal to ""

    if [[ ! ($column_wh == "") ]] ; then
    	column_wh=$(getColumnIndex $table_name $column);
    	#echo $column_wh	
    	column_wh=($((column_wh/4+1)))
    	if [[ $'$column_wh$op$val' ]]; then
    		NR=($(awk 'BEGIN{FS=":"}{if ($'$column_wh$op$val')print NR}' $1))
    		f="${NR[0]}"
		l="${NR[-1]}"
		sed -i "${f},${l}d" $1
	fi
    else {
    	sed -i "d" $table_name
    }
    fi  
 }