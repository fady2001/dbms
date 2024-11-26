#!/usr/bin/bash

export CURRENT_DB_PATH="."
export CURRENT_DB_NAME="iti"

source ./metadata.sh

input1="name=fady or name = adel"
echo $input1    

declare -a anded
declare -a ored


# Replace "and" with a delimiter and split by that delimiter
IFS=';' read -r -a ored <<< $(echo $input1 | sed 's/ or /;/g')
# loop through the ored array
for i in "${!ored[@]}"; do
    # if the element contains "and", replace it with a delimiter and split by that delimiter and remove from ored array
    if [[ ${ored[$i]} == *" and "* ]]; then
        IFS=';' read -r -a anded <<< $(echo "${ored[$i]}" | sed 's/ and /;/g')
        unset ored[$i]
    fi
done
# IFS='=' read -r -a condition <<< ${anded[0]}
# echo condition: ${condition[0]} ${condition[1]}
# echo anded: ${anded[@]}
# echo ored: ${ored[@]}


# Function to handle the comparison logic
function evaluate_condition() {
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

# Read row by row from file
while IFS= read -r line; do
    # Split the line by delimiter
    IFS=':' read -r -a fields <<< $line
    and_flag=1
    # if ored is empty then set or_flag to 1
    [[ ${#ored[@]} -eq 0 ]] && or_flag=1 || or_flag=0
    for cond in "${anded[@]}"; do
        # Capture operator from cond either = or <> or > or < or >= or <=
        operator=$(echo $cond | grep -oP '([<>]=?|!?=)')
        # Capture the field name from cond
        cond_LHS=$(echo $cond | sed -r "s/(.*)${operator}(.*)/\1/" | tr -d ' ')
        cond_RHS=$(echo $cond | sed -r "s/(.*)${operator}(.*)/\2/" | tr -d ' ')
        # Get the index of the field name in the fields array
        index=$(getColumnIndex emp $cond_LHS)
        #actual index in the table file equals (index/4)+1
        index=$((index/4))
        # Evaluate the condition
        result=$(evaluate_condition "$operator" "${fields[$index]}" "$cond_RHS")
        if [[ $result -eq 0 ]]; then
            and_flag=0
            break
        fi
    done
    for cond in "${ored[@]}"; do
        # Capture operator from cond either = or <> or > or < or >= or <=
        operator=$(echo $cond | grep -oP '([<>]=?|!?=)')
        # Capture the field name from cond
        cond_LHS=$(echo $cond | sed -r "s/(.*)${operator}(.*)/\1/" | tr -d ' ')
        cond_RHS=$(echo $cond | sed -r "s/(.*)${operator}(.*)/\2/" | tr -d ' ')        
        # Get the index of the field name in the fields array
        index=$(getColumnIndex emp $cond_LHS)
        #actual index in the table file equals (index/4)+1
        index=$((index/4))
        # Evaluate the condition
        # echo field: ${fields[$index]} operator: $operator cond_RHS: $cond_RHS
        # echo op: $operator fld: ${#fields[$index]} cond: ${#cond_RHS} 
        result=$(evaluate_condition "$operator" "${fields[$index]}" "$cond_RHS")
        if [[ $result -eq 1 ]]; then
            or_flag=1
            break
        fi
    done
    if [[ $and_flag -eq 1 && $or_flag -eq 1 ]]; then
        echo $line
    fi
done < emp