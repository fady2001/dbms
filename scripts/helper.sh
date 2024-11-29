#!/usr/bin/bash

################################################################################
#
# This file contains helper functions that can be used in other scripts         
#
################################################################################

# helper function that takes 3 arguments: text, foreground color, background color and prints the text with the specified colors
# $1: text
# $2: foreground color
# $3: background color
function print() {
    # Define color codes for foreground (text) colors
    RED='\033[31m'
    GREEN='\033[32m'
    YELLOW='\033[33m'
    BLUE='\033[34m'
    MAGENTA='\033[35m'
    CYAN='\033[36m'
    WHITE='\033[37m'
    BLACK='\033[30m'

    # Define background color codes
    BG_RED='\033[41m'
    BG_GREEN='\033[42m'
    BG_YELLOW='\033[43m'
    BG_BLUE='\033[44m'
    BG_MAGENTA='\033[45m'
    BG_CYAN='\033[46m'
    BG_WHITE='\033[47m'

    # Reset code
    RESET='\033[0m'

    # Default color settings
    fg_color=$RESET
    bg_color=$RESET

    # Set foreground color based on input
    case "$2" in
        "red") fg_color=$RED ;;
        "green") fg_color=$GREEN ;;
        "yellow") fg_color=$YELLOW ;;
        "blue") fg_color=$BLUE ;;
        "magenta") fg_color=$MAGENTA ;;
        "cyan") fg_color=$CYAN ;;
        "white") fg_color=$WHITE ;;
        *) fg_color=$RESET ;;  # Default to no color if not recognized
    esac

    # Set background color based on input
    case "$3" in
        "red") bg_color=$BG_RED ;;
        "green") bg_color=$BG_GREEN ;;
        "yellow") bg_color=$BG_YELLOW ;;
        "blue") bg_color=$BG_BLUE ;;
        "magenta") bg_color=$BG_MAGENTA ;;
        "cyan") bg_color=$BG_CYAN ;;
        "white") bg_color=$BG_WHITE ;;
        *) bg_color=$RESET ;;  # Default to no background if not recognized
    esac

    # Print the text with the specified foreground and background colors
    echo -e "${fg_color}${bg_color}$1${RESET}" >&2
}

# helper function that takes a string and check if it is alphanumeric or not
# returns 1 if it is alphanumeric, 0 otherwise
function isAlphaNumeric() {
    if [[ $1 =~ ^[a-zA-Z0-9]+$ ]]; then
        echo 1
    else
        echo 0
    fi
}

# helper function that takes a file name and directory and checks 
# if it exists or not in the given directory
# if no given directory, it checks in the current directory
# returns 1 if it exists, 0 otherwise
function fileExists() {
    if [ -z "$2" ]; then
        if [ -e "$1" ]; then
            echo 1
        else
            echo 0
        fi
    else
        if [ -e "$2/$1" ]; then
            echo 1
        else
            echo 0
        fi
    fi
}


# helper function that takes a dir name and another dir and checks 
# if it exists or not in the given directory
# if no given directory, it checks in the current directory
# returns 1 if it exists, 0 otherwise
function dirExists() {
    if [ -z "$2" ]; then
        if [ -d "$1" ]; then
            echo 1
        else
            echo 0
        fi
    else
        if [ -d "$2/$1" ]; then
            echo 1
        else
            echo 0
        fi
    fi
}

# helper function that takes a name of file or directory and checks its length
# returns 1 if it is greater than 255, 0 otherwise
function isNameTooLong() {
    if [ ${#1} -gt 255 ]; then
        echo 1
    else
        echo 0
    fi
}


# helper function that takes a path and checks its length 
# if the path is not given, it checks the current directory
# returns 1 if it is greater than 4096, 0 otherwise
function isPathTooLong() {
    if [ -z "$1" ]; then
        if [ ${#PWD} -gt 4096 ]; then
            echo 1
        else
            echo 0
        fi
    else
        if [ ${#1} -gt 4096 ]; then
            echo 1
        else
            echo 0
        fi
    fi
}

# helper function that take a path and checks for its read permission
# if the path is not given, it checks the current directory
# returns 1 if it has read permission, 0 otherwise
function hasReadPermission() {
    if [ -z "$1" ]; then
        if [ -r "$PWD" ]; then
            echo 1
        else
            echo 0
        fi
    else
        if [ -r "$1" ]; then
            echo 1
        else
            echo 0
        fi
    fi
}

# helper function that take a path and checks for its write permission
# if the path is not given, it checks the current directory
# returns 1 if it has write permission, 0 otherwise
function hasWritePermission() {
    if [ -z "$1" ]; then
        if [ -w "$PWD" ]; then
            echo 1
        else
            echo 0
        fi
    else
        if [ -w "$1" ]; then
            echo 1
        else
            echo 0
        fi
    fi
}

# helper function that take a path and checks for its execute permission
# if the path is not given, it checks the current directory
# returns 1 if it has execute permission, 0 otherwise
function hasExecutePermission() {
    if [ -z "$1" ]; then
        if [ -x "$PWD" ]; then
            echo 1
        else
            echo 0
        fi
    else
        if [ -x "$1" ]; then
            echo 1
        else
            echo 0
        fi
    fi
}


# helper function that takes the table path and the column name and checks if the column contains duplicates or not
# $1: table path
# $2: column index
# returns 1 if the column contains duplicates, 0 otherwise
function containsDublicates (){
    echo $(awk -v col="$2" 'BEGIN { FS=":"; flag =0;} { if ($col in seen) {
            print 1
            flag=1
            exit

            } else {
                seen[$col] = 1;
            }} END { if (!flag)print 0}' "$1")
}

# helper function that takes the table path and the column name and checks if the column contains nulls or not
# $1: table path
# $2: column index
# returns 1 if the column contains nulls, 0 otherwise
function containsNulls () {
    echo $(awk -v col="$2" 'BEGIN { FS=":";  flag =0;} { if ($col == "" ) {
		print 1
		flag=1
		exit

        } else {
            flag = 0
        }} END { if (!flag) print 0}' "$1")
}

# helper function that takes the table path and array of column names and checks all constraints on the given columns
# $1: table path
# $2: array of column names
# returns 1 if all constraints are met, 0 otherwise
function satisfyConstraints() {
    for column in $2; do
        # check if the column contains duplicates
        index=$(getColumnIndex $1 $column)
        index=$((index/4+1))
        # check if the column has unique constraint but contains duplicates
        if [[ $(getColumnUniqueConstraint $1 $column) -eq 1 && $(containsDublicates $1 $index) -eq 1 ]]; then
            print "Error: Column $column has unique constraint" "white" "red"
            echo 0
            return
        fi

        # check if the column has not null constraint but contains nulls
        if [[ $(getColumnNullConstraint $1 $column) -eq 1 && $(containsNulls $1 $index) -eq 1 ]]; then
            print "Error: Column $column has not null constraint but contains nulls" "white" "red"
            echo 0
            return
        fi

        # check if the column has primary key constraint but contains nulls
        pk=$(getPrimaryKey $1)
        #get index of the primary key
        pk=$(getColumnIndex $1 $pk)
        pk=$((pk/4+1))
        if [[ $pk -eq $index && $(containsNulls $1 $index) -eq 1 ]]; then
            print "Error: Column $column has primary key constraint but contains nulls" "white" "red"
            echo 0
            return
        fi

        # check if the column has primary key constraint but contains duplicates
        if [[ $pk -eq $index && $(containsDublicates $1 $index) -eq 1 ]]; then
            print "Error: Column $column has primary key constraint" "white" "red"
            echo 0
            return
        fi
    done
    echo 1
}

# helper function that takes the table path and the column index and value and checks if value exists in the column or not
# $1: table path
# $2: column index
# $3: value
# returns 1 if the value exists in the column, 0 otherwise
function valueExists() {
    if awk -F':' -v col="$2" -v val="$3" '
    BEGIN { found=0 }
    {
        if ($col == val) {
            found=1
            exit
        }
    }
    END { exit !found }
    ' "$1"; then
        echo 1
    else
        echo 0
    fi
}

# helper function that takes a input and checks if it is contains only digits or not
# returns 1 if it contains only digits, 0 otherwise
function isNumber() {
    if [[ $1 =~ ^-?[0-9]+$ ]]; then
        echo 1
    else
        echo 0
    fi
}

# helper function that takes a input and checks if it is contains any character except ':'
# returns 1 if it contains only alphabets, 0 otherwise
function containsColon() {
    if [[ $1 =~ : ]]; then
        echo 1
    else
        echo 0
    fi
}

# Function to handle the comparison logic. it takes 3 arguments: operator, field_value, condition_value
# returns 1 if the condition is true, 0 if the condition is false, -1 if the operator is not recognized
function evaluate_operator() {
    operator=$1
    field_value=$2
    condition_value=$3

    # Check if the field_value and condition_value are numbers
    if [[ $condition_value =~ ^-?[0-9]+$ ]]; then
        # Numeric comparison
        case $operator in
            "=")
                [[ $field_value -eq $condition_value ]] && echo 1 || echo 0
                ;;
            "!=")
                [[ $field_value -ne $condition_value ]] && echo 1 || echo 0
                ;;
            ">")
                [[ $field_value -gt $condition_value ]] && echo 1 || echo 0
                ;;
            "<")
                [[ $field_value -lt $condition_value ]] && echo 1 || echo 0
                ;;
            ">=")
                [[ $field_value -ge $condition_value ]] && echo 1 || echo 0
                ;;
            "<=")
                [[ $field_value -le $condition_value ]] && echo 1 || echo 0
                ;;
            *)
                echo -1
                ;;
        esac
    else
        # String comparison
        case $operator in
            "=")
                [[ $field_value == $condition_value ]] && echo 1 || echo 0
                ;;
            "!=")
                [[ $field_value != $condition_value ]] && echo 1 || echo 0
                ;;
            ">")
                [[ $field_value > $condition_value ]] && echo 1 || echo 0
                ;;
            "<")
                [[ $field_value < $condition_value ]] && echo 1 || echo 0
                ;;
            *)
                echo -1
                ;;
        esac
    fi
}

# function to check if where conditions are met in the passed record or not
# $1: table name
# $2: record
# $3: where conditions
# returns 1 if the conditions are met, 0 if not met, -1 if the operator is not recognized
function evaluateConditions() {

    declare -a anded
    declare -a ored

    # Replace "and" with a delimiter and split by that delimiter
    IFS=';' read -r -a ored <<< $(echo $3 | sed 's/ or /;/g')
    # loop through the ored array
    for i in "${!ored[@]}"; do
        # if the element contains "and", replace it with a delimiter and split by that delimiter and remove from ored array
        if [[ ${ored[$i]} == *" and "* ]]; then
            IFS=';' read -r -a anded <<< $(echo "${ored[$i]}" | sed 's/ and /;/g')
            unset ored[$i]
        fi
    done

    # print "anded: ${anded[@]}" "white" "green"
    # print "ored: ${ored[@]}" "white" "green"

    # Split the line by delimiter
    IFS=':' read -r -a fields <<< $2
    and_flag=1
    # if ored is empty then set or_flag to 1
    [[ ${#ored[@]} -eq 0 ]] && or_flag=1 || or_flag=0
    for cond in "${anded[@]}"; do
        # Capture operator from cond either = or != or > or < or >= or <=
        operator=$(echo $cond | grep -oP '([<>]=?|!?=)')
        # Capture the field name from cond
        cond_LHS=$(echo $cond | sed -r "s/(.*)${operator}(.*)/\1/" | xargs)
        cond_RHS=$(echo $cond | sed -r "s/(.*)${operator}(.*)/\2/" | xargs)
        # Get the index of the field name in the fields array
        index=$(getColumnIndex $1 $cond_LHS)
        #actual index in the table file equals (index/4)+1
        index=$((index/4))
        # Evaluate the condition
        result=$(evaluate_operator "$operator" "${fields[$index]}" "$cond_RHS")
        if [[ $result -eq -1 ]]; then
            echo -1
            return
        fi
        if [[ $result -eq 0 ]]; then
            and_flag=0
            break
        fi
    done
    for cond in "${ored[@]}"; do
        # Capture operator from cond either = or !> or > or < or >= or <=
        operator=$(echo $cond | grep -oP '([<>]=?|!?=)')
        # Capture the field name from cond
        cond_LHS=$(echo $cond | sed -r "s/(.*)${operator}(.*)/\1/" | xargs)
        cond_RHS=$(echo $cond | sed -r "s/(.*)${operator}(.*)/\2/" | xargs)        
        # Get the index of the field name in the fields array
        index=$(getColumnIndex $1 $cond_LHS)
        #actual index in the table file equals (index/4)+1
        index=$((index/4))
        # Evaluate the condition
        # echo field: ${fields[$index]} operator: $operator cond_RHS: $cond_RHS
        # echo op: $operator fld: ${#fields[$index]} cond: ${#cond_RHS} 
        result=$(evaluate_operator "$operator" "${fields[$index]}" "$cond_RHS")
        # print "result: $result" "white" "green"
        if [[ $result -eq -1 ]]; then
            echo -1
            return
        fi
        if [[ $result -eq 1 ]]; then
            or_flag=1
            break
        fi
    done
    if [[ $and_flag -eq 1 && $or_flag -eq 1 ]]; then
        # print "1" "white" "green"
        echo 1
    else
        # print "0" "white" "red"
        echo 0
    fi
}