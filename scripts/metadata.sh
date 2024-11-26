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
# $1: table name
function addTableToMetadata() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        echo "Metadata file for database $CURRENT_DB_NAME does not exist"
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

    # Remove the trailing ':' from the last column
    tableMetadata=${tableMetadata%?}

    # Append the table metadata to the metadata file

    echo "$1:$tableMetadata" >> "$CURRENT_DB_PATH/.$CURRENT_DB_NAME"
    echo "Table $1 added to metadata."
}

# function that takes and table name and column name and return the column index
# $1: table name
# $2: column name
# return: if column name exists return the index of the column, otherwise return -1
function getColumnIndex() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        echo "Metadata file for database $CURRENT_DB_NAME does not exist"
        return
    fi
    # Variable for column index (initialized to -1, in case we don't find it)
    column_index=-1

    # Use awk to search for the column name
    column_index=$(awk -v table_name="$1" -v column_name="$2" '
    BEGIN {FS=":"}
    {
        if ($1 == table_name) {
            for (i = 2; i <= NF; i+=4) {
                if ($i == column_name) {
                    print i
                    exit
                }
            }
        }
    }
    ' "$CURRENT_DB_PATH/.$CURRENT_DB_NAME")

    if [[ -z "$column_index" ]]; then
        column_index=-1
    fi

    echo "$column_index"
}

# function that takes and table name and column name and return the column type
# $1: table name
# $2: column name
# return: if column name exists return the type of the column, otherwise return -1
function getColumnType() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        echo "Metadata file for database $CURRENT_DB_NAME does not exist"
        return
    fi
    # Variable for column type (initialized to -1, in case we don't find it)
    column_type=-1

    # Use awk to search for the column name
    column_type=$(awk -v  table_name="$1" -v column_name="$2" '
    BEGIN {FS=":"}
    {
        if ($1 == table_name) {
            for (i = 2; i <= NF; i+=4) {
                if ($i == column_name) {
                    print $(i+1)
                    exit
                }
            }
        }
    }
    ' "$CURRENT_DB_PATH/.$CURRENT_DB_NAME")

    if [[ -z "$column_type" ]]; then
        column_type=-1
    fi

    echo "$column_type"
}


# function that takes and table name and return the column size
# $1: table name
# $2: column name
# return: if column name exists return the size of the column, otherwise return -1
function getColumnSize() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        echo "Metadata file for database $CURRENT_DB_NAME does not exist"
        return
    fi
    # Variable for column size (initialized to -1, in case we don't find it)
    column_size=-1

    # Use awk to search for the column name
    column_size=$(awk -v  table_name="$1" -v column_name="$2" '
    BEGIN {FS=":"}
    {
        if ($1 == table_name) {
            for (i = 2; i <= NF; i+=4) {
                if ($i == column_name) {
                    print $(i+2)
                    exit
                }
            }
        }
    }
    ' "$CURRENT_DB_PATH/.$CURRENT_DB_NAME")

    if [[ -z "$column_size" ]]; then
        column_size=-1
    fi

    echo "$column_size"
}

# function that takes and table name and return the primary key column name
# $1: table name
# return: if primary key exists return the primary key column name, otherwise return -1
function getPrimaryKey() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        echo "Metadata file for database $CURRENT_DB_NAME does not exist"
        return
    fi
    # Variable for primary key (initialized to -1, in case we don't find it)
    primary_key=-1

    # Use awk to search for the primary key
    primary_key=$(awk -v  table_name="$1" '
    BEGIN {FS=":"}
    {
        if ($1 == table_name) {
            for (i = 5; i <= NF; i+=4) {
                if (substr($i, 1, 1) == "y") {
                    print $(i-3)
                    exit
                }
            }
        }
    }
    ' "$CURRENT_DB_PATH/.$CURRENT_DB_NAME")

    if [[ -z "$primary_key" ]]; then
        primary_key=-1
    fi

    echo "$primary_key"
}

# function that takes and table name and column name and return the column null constraint
# $1: table name
# $2: column name
# return: if column name exists return the null constraint of the column, otherwise return -1
function getColumnNullConstraint() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        echo "Metadata file for database $CURRENT_DB_NAME does not exist"
        return
    fi
    # Variable for column null constraint (initialized to -1, in case we don't find it)
    column_null_constraint=-1

    # Use awk to search for the column name
    column_null_constraint=$(awk -v  table_name="$1" -v column_name="$2" '
    BEGIN {FS=":"}
    {
        if ($1 == table_name) {
            for (i = 5; i <= NF; i+=4) {
                if ($(i-3) == column_name) {
                    if (substr($i, 2, 1) == "y") {
                        print "true"
                        exit
                    } else {
                        print "false"
                        exit
                    }
                }
            }
        }
    }
    ' "$CURRENT_DB_PATH/.$CURRENT_DB_NAME")

    if [[ -z "$column_null_constraint" ]]; then
        column_null_constraint=-1
    fi

    echo "$column_null_constraint"
}

# function that takes and table name and column name and return the column unique constraint
# $1: table name
# $2: column name
# return: if column name exists return the unique constraint of the column, otherwise return -1
function getColumnUniqueConstraint() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        echo "Metadata file for database $CURRENT_DB_NAME does not exist"
        return
    fi
    # Variable for column unique constraint (initialized to -1, in case we don't find it)
    column_unique_constraint=-1

    # Use awk to search for the column name
    column_unique_constraint=$(awk -v  table_name="$1" -v column_name="$2" '
    BEGIN {FS=":"}
    {
        if ($1 == table_name) {
            for (i = 5; i <= NF; i+=4) {
                if ($(i-3) == column_name) {
                    if (substr($i, 3, 1) == "y") {
                        print "true"
                        exit
                    } else {
                        print "false"
                        exit
                    }
                }
            }
        }
    }
    ' "$CURRENT_DB_PATH/.$CURRENT_DB_NAME")

    if [[ -z "$column_unique_constraint" ]]; then
        column_unique_constraint=-1
    fi

    echo "$column_unique_constraint"
}


# helper function that takes and table name and return column names in the table
# $1: table name
# return: if table exists return the column names as an array, otherwise return -1
function getColumnNames() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        echo "Metadata file for database $CURRENT_DB_NAME does not exist"
        return
    fi

    # Initialize an empty array for column names
    column_names=()

    # Use awk to search for the table name and extract column names
    column_names_str=$(awk -v table_name="$1" '
    BEGIN {FS=":"}
    {
        if ($1 == table_name) {
            for (i = 2; i <= NF; i+=4) {
                printf "%s ", $i
            }
        }
    }
    ' "$CURRENT_DB_PATH/.$CURRENT_DB_NAME")

    # Convert the space-separated string to an array
    IFS=' ' read -r -a column_names <<< "$column_names_str"

    # Check if the array is empty and set to -1 if no columns were found
    if [[ ${#column_names[@]} -eq 0 ]]; then
        column_names=(-1)
    fi

    # Print the array elements
    echo "${column_names[@]}"
}