#!/usr/bin/bash

#####################################################################################################
# *** the metadata file is hidden in the database directory and has the same name as the database ***
#
# This file contains scripts to create metadata file for the database
# and to store the metadata of the tables in the database
#
#####################################################################################################

# Each record in the metadata file represents a table in the database and has the following format:
# Table name : column1 name - column1 data type - column1 size - isPK isNull isUnique : column2 name - column2 data type - column2 size - isPK isNull isUnique : ...
# e.g., users : id - int - 4 - yyy : name - varchar - 20 - false : email - varchar - 50 - nyy

# Function that creates a new metadata file for the database
function createMetadataFile() {
    # there are no checks needed as they are already checked in the database.sh script
    # Create the hidden metadata file inside the database directory
    touch "$1/.$1"
    echo "Metadata file created for database $1"
}

# Function that adds a new table to the metadata file
# $1: database name
# $2: table name
function addTableToMetadata() {
    # Check if the metadata file exists
    if [[ ! -f ".$1" ]]; then
        echo "Metadata file for database $1 does not exist"
        return
    fi

    # Ask for table name
    read -p "Enter the number of columns: " columnCount

    # Validate the column count using regex and loop until a valid number is entered and not equal to zero
    while [[ ! $columnCount =~ ^[0-9]+$ || $columnCount -eq 0 ]]; do
        echo "Column count should be a number greater than zero"
        read -p "Enter the number of columns: " columnCount
    done

    # Initialize an empty string to store column definitions
    tableMetadata=""
    # flag to check if the primary key is already set
    isPrimaryKeySet=0

    # Loop to read column details for each column in a single line
    for ((i = 1; i <= $columnCount; i++)); do
        echo "Enter details for column $i in the format: name type size isPK isNull isUnique (e.g., id int 4 yyy)"
        read -p "Column $i details: " columnDetails

        # Split the input by space into an array
        IFS=' ' 
        read -r columnName columnType columnSize columnConstraints <<< "$columnDetails"

        # validate the column name
        if [[ $(isAlphaNumeric $columnName) -eq 0 ]]; then
            echo "Column name should be alphanumeric"
            # decrement the counter to re-enter the column details
            ((i--))
            continue
        fi

        # validate the column type either int or varchar
        if [[ $columnType != "int" && $columnType != "varchar" ]]; then
            echo "Column type should be either int or varchar"
            ((i--))
            continue
        fi

        # validate the column size must be a number not equal to zero
        if [[ ! $columnSize =~ ^[0-9]+$ || $columnSize -eq 0 ]]; then
            echo "Column size should be a number greater than zero"
            ((i--))
            continue
        fi

        # validate the column constraints to be any combination of y or n limited to 3 characters
        if [[ ! $columnConstraints =~ ^[yn]{3}$ ]]; then
            echo "Column constraints should be any combination of y or n limited to 3 characters"
            ((i--))
            continue
        fi

        # check if the primary key is already set
        if [[ ${columnConstraints:0:1} == 'y' && $isPrimaryKeySet -eq 1 ]]; then
            echo "Primary key is already set"
            ((i--))
            continue
        else
            isPrimaryKeySet=1
        fi

        # Construct the column metadata in the required format
        # append the column metadata to the table metadata in a new line
        tableMetadata+="$columnName:$columnType:$columnSize:$columnConstraints:"
    done

    # Remove the trailing ' : ' from the last column
    tableMetadata="${tableMetadata% : }"

    # Append the table metadata to the metadata file
    echo "$2 : $tableMetadata" >> ".$1"
    echo "Table $2 added to metadata."
}

# function that take the database name and table name and column name and return the column index
# $1: database name
# $2: table name
# $3: column name
# return: if column name exists return the index of the column, otherwise return -1
function getColumnIndex() {
    # Check if the metadata file exists
    if [[ ! -f ".$1" ]]; then
        echo "Metadata file for database $1 does not exist"
        return
    fi
    # Variable for column index (initialized to -1, in case we don't find it)
    column_index=-1

    # Use awk to search for the column name
    column_index=$(awk -v column_name="$3" '
    BEGIN {FS=":"}
    {
        for (i = 2; i <= NF; i+=4) {
            if ($i == column_name) {
                print i
                exit
            }
        }
    }
    ' ".$1")

    if [[ -z "$column_index" ]]; then
        column_index=-1
    fi

    echo "$column_index"
}