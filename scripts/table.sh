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
 function selectFromTable() {
    #Global variable to print
  
    local output=""
    # check if table exists
    if [[ $(fileExists $1) -eq 0 ]]; then
        output+="Table does not exist\n"
        echo -e "$output"
        return
    fi
    IFS=','
  
    # Set the field separator to a comma
    read -p "Enter The Columns You Would Like To Select Seperated by , (* for all): " -a columns
 
    read -p "Enter The Condition (Empty for NO Condition): " condition
    # Triming the white spaces
    condition=$(echo "$condition" | sed 's/[[:space:]]*\([=!<>]=\|[=<>]\)[[:space:]]*/\1/g' | xargs)
    
    set -f
    if [[ "$columns" =~ ^\ *\*\ *$ ]]; then
        columns=("*")
    fi	
    # Loop through each column name
    declare -a indecies
    if  [[ "$columns" != "*" ]]; then
        # Triming the white spaces
        for i in ${!columns[@]}; do
        	columns[$i]=$(echo ${columns[$i]} | tr -d '[:space:]')
    	done
    	for column in ${columns[@]}; do
	        # get column index   		
        	index=$(getColumnIndex $1 "$column")
        	# check if the column exists
        	if [[ $index -eq -1 ]]; then
        	    	 output+="Column $column does not exist in the table\n"
                	echo -e "$output"
        	else
        	    # actual index in the table file equals (index/4)+1
        	    indecies+=($((index/4+1)))
        	fi
    	done
    fi
    
    indecies=$(IFS=,; echo "${indecies[*]}") # Join values with a comma
    
    # Extracting 
    # Extract the column name (everything before the first operator)
    column_wh=$(echo "$condition" | grep -oE '^[a-zA-Z_][a-zA-Z0-9_]*')
    
    # Handle if the where condition column name is entered wrong
    column_names=$(getColumnNames $1)
    # Check if column is valid
    if [[ "$column_wh" != "" && ! " ${column_names[@]} " =~ " ${column_wh} " ]]; then
        output+="Column $column_wh is not recognized in WHERE statement\n"
        echo -e "$output"
        return
    fi
    # Extract the operator 
    op=$(echo "$condition" | grep -oE '(!=|<=|>=|=|<|>)')

    # Extract the value (everything after the operator)
    val=$(echo "$condition" | sed -E "s/^[a-zA-Z_][a-zA-Z0-9_]*${op}//")
    
    if [[ $(valid_op $op) != 1 ]]; then
    	output+="Operator $op is not recognized\n"
        echo -e "$output"
        return
    fi
    # Reset IFS to default
    unset IFS

    # If there is no where statment
    if [[ ($column_wh == "") ]] ; then

	#If the user wants to select all the columns
	if [[ "$columns" == "*" ]]; then
		IFS=' ' read -r -a names <<< "$(getColumnNames $1)"    
		for column in ${names[@]}; do
			output="$output$column:"
		    done
		    # Remove trailing colon if it exists
		    output="${output%:}"
		    # Add a newline after the loop
		    output="$output\n"
    		output+=$(sed -n 'p' $1)

	#If the user wants to certain columns
    	else 
    		for column in ${columns[@]}; do
                output="$output$column:"
		done
		# Remove trailing colon if it exists
		output=${output%:}
		output="$output\n"
    		output+=$(awk -v ind="$indecies" 'BEGIN {FS=":"; split(ind, arr, ",");} {for (i in arr) { printf "%s:",$arr[i]}printf"\n"}' $1)

    	fi
    # there is a where statment
    
    else
    	temp=$(getColumnIndex $1 $column_wh);
    	column_wh=$((temp/4+1));
    	
    	if [[ "$val" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
	    is_numeric=1  # Numeric
	elif [[ "$val" =~ ^[a-zA-Z_][a-zA-Z0-9_]*(\ +[a-zA-Z0-9_]+)*$ ]]; then
    	    is_numeric=0  # String
	else
	    output="Invalid Value"
	    echo -e "$output"
	    return
	fi
    	# If the user wants to select all the columns
    	if [[ "$columns" == "*" ]]; then
    		NR=($(awk -v col="$column_wh" -v op="$op" -v val="$val" -v is_numeric="$is_numeric" '
		BEGIN {
		    FS = ":"; 
		}
		{
		    # Construct condition 
		    if (is_numeric == 1) {
			if ((op == ">" && $col > val) || 
			    (op == "<" && $col < val) || 
			    (op == "=" && $col == val) || 
			    (op == "!=" && $col != val)||
			    (op == ">=" && $col >= val)||
			    (op == "<=" && $col <= val)) {
			    print NR;
			}
		    } else { # val is a string
			if ((op == "=" && $col == val) || 
			    (op == "!=" && $col != val)) {
			    print NR;
			}
		    }
		}' "$1"))
		if [[ ${#NR[@]} -gt 0 ]]; then
	  	f="${NR[0]}"
	  	l="${NR[-1]}"
		IFS=' ' read -r -a names <<< "$(getColumnNames $1)"    
		for column in ${names[@]}; do
			output="$output$column:"
		done
		# Remove trailing colon if it exists
		output="${output%:}"
		# Add a newline after the loop
		output="$output\n"
		output+=$(sed -n "${f},${l}p" $1)  
		fi      	
	# Selecting specific columns
	else 	 
		for column in ${columns[@]}; do
			output+="$column:"
		done
		# Remove trailing colon if it exists and add a newline
		output="${output%:}\n"
	        
	        output+=$(awk -v col="$column_wh" -v op="$op" -v val="$val" -v ind="$indecies" -v is_numeric="$is_numeric" '
		BEGIN {FS = ":"; OFS = ":"; split(ind, arr, ",");}
		{
		    # Construct condition dynamically based on operator
		    if (is_numeric == 1) {
			if ((op == ">" && $col > val) || 
			    (op == "<" && $col < val) || 
			    (op == "=" && $col == val) || 
			    (op == "!=" && $col != val) ||
			    (op == ">=" && $col >= val)||
			    (op == "<=" && $col <= val)) {
			    for (i = 1; i <= length(arr); i++) {
			printf "%s", $arr[i];
			if (i < length(arr)) {
			    printf OFS;
			} else {
			    printf "\n";
			}
		    }
			}
		    } else { # val is a string
			if ((op == "=" && $col == val) || 
			    (op == "!=" && $col != val)) {
			    for (i = 1; i <= length(arr); i++) {
			printf "%s", $arr[i];
			if (i < length(arr)) {
			    printf OFS;
			} else {
			    printf "\n";
			}
		    }
			}
		    }
		}' "$1")
	fi
    fi
    
    set +f
    echo -e "$output"
 }





# # function that delete from a Table
 function deleteFromTable() {
    local output=""
    # check if table exists
    if [[ $(fileExists $1) -eq 0 ]]; then
        print "Table does not exist" "white" "red"
        return
    fi
    
    #read -p "Enter the Table name: "  table_name
    read -p "Enter Condition (e.g., age=35): " condition
    
    #Triming the white spaces
    condition=$(echo "$condition" | sed 's/[[:space:]]*\([=!<>]=\|[=<>]\)[[:space:]]*/\1/g' | xargs)

       # Extracting 
    # Extract the column name (everything before the first operator)
    column_wh=$(echo "$condition" | grep -oE '^[a-zA-Z_][a-zA-Z0-9_]*')
    
    # Handle if the where condition column name is entered wrong
    column_names=$(getColumnNames $1)
    
    # Check if column is valid
    if [[ "$column_wh" != "" && ! " ${column_names[@]} " =~ " ${column_wh} " ]]; then
        output+="Column $column_wh is not recognized in WHERE statement\n"
        echo -e "$output"
        return
    fi
    # Extract the operator 
    op=$(echo "$condition" | grep -oE '(!=|<=|>=|=|<|>)')

    if [[ $(valid_op $op) != 1 ]]; then
    	output+="Operator $op is not recognized\n"
        echo -e "$output"
        return
    fi    
    # Extract the value (everything after the operator)
    val=$(echo "$condition" | sed -E "s/^[a-zA-Z_][a-zA-Z0-9_]*${op}//")


    # if there is a where statment 
    if [[ -n "$column_wh" ]]; then
    	column_wh=$(getColumnIndex $1 $column_wh);
    	column_wh=$((column_wh / 4 + 1))
    	if [[ "$val" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
	    is_numeric=1  # Numeric
	elif [[ "$val" =~ ^[a-zA-Z_][a-zA-Z0-9_]*(\ +[a-zA-Z0-9_]+)*$ ]]; then
    	    is_numeric=0  # String
	else
	    output="Invalid Value"
	    echo -e "$output"
	    return
	fi
    		NR=($(awk -v col="$column_wh" -v op="$op" -v val="$val" -v is_numeric="$is_numeric" '
		BEGIN { FS = ":"; }
		{
		    if (is_numeric == 1) {
			if ((op == ">" && $col > val) || (op == "<" && $col < val) || (op == "=" && $col == val) || (op == "!=" && $col != val)|| (op == ">=" && $col >= val)|| (op == "<=" && $col <= val) ) {
			    print NR;
			}
		    } else {
			if ((op == "=" && $col == val) || (op == "!=" && $col != val)) {
			    print NR;
			}
		    }
		}' "$1"))
		
		if [[ ${#NR[@]} -gt 0 ]]; then
			f="${NR[0]}"
			l="${NR[-1]}"	
			sed -i "${f},${l}d" $1	
			output="Records deleted successfully"
			echo -e  "$output"
		fi
    #If there is no where statment then we delete all the records
    else 
    	sed -i "d" $1
    	output="Records deleted successfully"
        echo -e  "$output"
    
    fi  
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

# function to delete a column from the table
# $1: table name
# $2: column name
function alterTableDropColumn () {
    # delete the column from the metadata
    if [[ $(deleteColumnFromMetadata $1 $2) -eq -1 ]]; then
        echo -1
        return
    fi
    # get column index
    column_index=$(getColumnIndex $1 $2)
    column_index=$(($column_index/4+1))

    # delete the column from the table file based on the column index
    awk -v col="$column_index" '
    BEGIN {
        FS = ":";
        OFS = ":";
    }
    {
        for (i = 1; i <= NF; i++) {
            if (i != col) {  
                printf "%s", $i;
                if (i < NF && i != col - 1) 
                    printf OFS;
            }
        }
        printf "\n"; 
    }' "$1" > .tmp
        
    print "Column dropped successfully" "white" "green"
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
                    break
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
                    break
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
                    break
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
                    break
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
                    break
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
                    break
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
