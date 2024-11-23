#!/usr/bin/bash

#####################################################################################################
# *** the metadata file is hidden in the database directory and has the same name as the database ***
#
# This file contains scripts to create metadata file for the database
# and to store the metadata of the tables in the database
#
#####################################################################################################

# Each record in the metadata file represents a table in the database and has the following format:
# Table name : column1 name - column1 data type - column1 size - column1 not null : column2 name - column2 data type - column2 size - column2 nullable : ...
# The first column is always the table's primary key.
# e.g., users : id - int - 4 - true : name - varchar - 20 - false : email - varchar - 50 - true

# Function that creates a new metadata file for the database
function createMetadataFile() {
    # there are no checks needed as they are already checked in the database.sh script
    # Create the hidden metadata file inside the database directory
    touch "$1/.$1"
    echo "Metadata file created for database $1"
}

# Function that adds a new table to the metadata file
function addTableToMetadata() {
    # Check if the metadata file exists
    if [[ ! -f ".$2" ]]; then
        echo "Metadata file for database $2 does not exist"
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

    # Loop to read column details for each column in a single line
    for ((i = 1; i <= $columnCount; i++)); do
        echo "Enter details for column $i in the format: name type size isNullable (e.g., id int 4 true)"
        read -p "Column $i details: " columnDetails

        # Split the input by space into an array
        IFS=' ' 
        read -r columnName columnType columnSize columnNotNull <<< "$columnDetails"

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

        # validate the column not null value
        if [[ $columnNotNull != "true" && $columnNotNull != "false" ]]; then
            echo "Column not null value should be either true or false"
            ((i--))
            continue
        fi

        # Construct the column metadata in the required format
        tableMetadata+="$columnName - $columnType - $columnSize - $columnNotNull : "
    done

    # Remove the trailing ' : ' from the last column
    tableMetadata="${tableMetadata% : }"

    # Append the table metadata to the metadata file
    echo "$1 : $tableMetadata" >> ".$2"
    echo "Table $1 added to metadata."
}

