#!/usr/bin/bash

#####################################################################################################
# *** the metadata file is hidden in the database directory and has the same name as the database ***
#
# This file contains scripts to create metadata file for the database
# and to store the metadata of the tables in the database
#
#####################################################################################################

# Each record in the metadata file represents a table in the database and has the following format:
# Table name : column1 name - column1 data type - column1 size - isPK notNull isUnique : column2 name - column2 data type - column2 size - isPK notNull isUnique : ...
# e.g., users : id - int - 4 - yyy : name - varchar - 20 - false : email - varchar - 50 - nyy

# Function that creates a new metadata file for the database
function createMetadataFile() {
    # there are no checks needed as they are already checked in the database.sh script
    # Create the hidden metadata file inside the database directory
    touch "$1/.$1"
    print "Metadata file created for database $1 successfully" "white" "green"
}

# Function that adds a new table to the metadata file
# $1: table name
function addTableToMetadata() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        print "Error: Metadata file for database $CURRENT_DB_NAME does not exist" "white" "red"
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
        echo "Enter details for column $i in the format: name type size isPK notNull isUnique (e.g., id int 4 yyy)"
        read -p "Column $i details: " columnDetails
        # end line
        echo

        # Split the input by space into an array
        IFS=' ' 
        read -r columnName columnType columnSize columnConstraints <<< "$columnDetails"

        # validate the column name
        if [[ $(isAlphaNumeric $columnName) -eq 0 ]]; then
            print "Column name should be alphanumeric" "white" "red"
            # decrement the counter to re-enter the column details
            ((i--))
            continue
        fi

        # validate the column type either int or varchar
        if [[ $columnType != "int" && $columnType != "varchar" ]]; then
            print "Column type should be either int or varchar" "white" "red"
            ((i--))
            continue
        fi

        # validate the column size must be a number not equal to zero
        if [[ ! $columnSize =~ ^[0-9]+$ || $columnSize -eq 0 ]]; then
            print "Column size should be a number greater than zero" "white" "red"
            ((i--))
            continue
        fi

        # validate the column constraints to be any combination of y or n limited to 3 characters
        if [[ ! $columnConstraints =~ ^[yn]{3}$ ]]; then
            print "Column constraints should be any combination of y or n limited to 3 characters" "white" "red"
            ((i--))
            continue
        fi

        # check if the primary key is already set
        if [[ ${columnConstraints:0:1} == 'y' && $isPrimaryKeySet -eq 1 ]]; then
            print "Primary key is already set" "white" "red"
            ((i--))
            continue
        else
            isPrimaryKeySet=1
        fi

        # Construct the column metadata in the required format
        # append the column metadata to the table metadata in a new line
        tableMetadata+="$columnName:$columnType:$columnSize:$columnConstraints:"
    done
    if [[ $isPrimaryKeySet -eq 0 ]]; then
        print "Error: Primary key is not set" "white" "red"
        return
    fi
    # Remove the trailing ':' from the last column
    tableMetadata=${tableMetadata%?}

    # Append the table metadata to the metadata file

    echo "$1:$tableMetadata" >> "$CURRENT_DB_PATH/.$CURRENT_DB_NAME"
    print "Table $1 added to metadata successfully." "white" "green"
}

# Function that drops a table from the metadata file
# $1: table name
# return: 1 if the table was dropped successfully, 0 otherwise
function dropTableFromMetadata() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        print "Error: Metadata file for database $CURRENT_DB_NAME does not exist" "white" "red"
        echo 0
        return
    fi

    # Remove the table metadata from the metadata file
    sed -i "/^$1:/d" "$CURRENT_DB_PATH/.$CURRENT_DB_NAME"
    print "Table $1 dropped from metadata successfully." "white" "green"
}

# function that takes and table name and column name and return the column index
# $1: table name
# $2: column name
# return: if column name exists return the index of the column, otherwise return -1
function getColumnIndex() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        print "Error: Metadata file for database $CURRENT_DB_NAME does not exist" "white" "red"
        echo -1
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
        print "Error: Metadata file for database $CURRENT_DB_NAME does not exist" "white" "red"
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
# return: 1 if the column is has not null constraint, 0 otherwise, -1 if the column does not exist
function getColumnNullConstraint() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        print "Error: Metadata file for database $CURRENT_DB_NAME does not exist" "white" "red"
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
                        print 1
                        exit
                    } else {
                        print 0
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
# return: 1 if the column is unique, 0 otherwise, -1 if the column does not exist
function getColumnUniqueConstraint() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        print "Error: Metadata file for database $CURRENT_DB_NAME does not exist" "white" "red"
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
                        print 1
                        exit
                    } else {
                        print 0
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
        print "Error: Metadata file for database $CURRENT_DB_NAME does not exist" "white" "red"
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

    # Print the array elements
    echo "${column_names[@]}"
}


# function takes the table name and the column name and the value and make sure that value can be inserted or set in the column
# $1: table name
# $2: column name
# $3: value
# returns 0 if the value can't be inserted, 1 otherwise
function followConstraints() {
    # get column index in metadata
    index=$(getColumnIndex $1 $2)
    # first check: if the column is primary key then it mustn't be empty and must be unique (not exist in the table)
    if [[ $(getPrimaryKey $1) == $2 ]]; then
        # check if the value is empty
        if [[ -z $3 || $3 == "null" ]]; then
            print "Error: Primary key must not null" "white" "red"
            echo 0
            return
        fi
        # check if the value exists in the table
        # index will be (index/4)+1 to map between index in metadata and index in the actual table
        if [[ $(valueExists $1 $((index/4+1)) $3) -eq 1 ]]; then
            print "Error: Primary key must be unique" "white" "red"
            echo 0
            return
        fi
    fi

    # second check: if the column is not null then it mustn't be empty
    if [[ $(getColumnNullConstraint $1 $2) -eq 1 ]]; then
        # check if the value is empty or "" or equal to null
        if [[ -z $3 || $3 == "null" ]]; then
            print "Error: $2 must not be null" "white" "red"
            echo 0
            return 
        fi
    fi

    # third check: if the column is unique then it must be unique (not exist in the table)
    if [[ $(getColumnUniqueConstraint $1 $2) -eq 1 ]]; then
        # check if the value exists in the table
        if [[ $(valueExists $1 $index $3) -eq 1 ]]; then
            print "Error: $2 must be unique" "white" "red"
            echo 0
            return
        fi
    fi

    # fourth check: check data type
    if [[ $(getColumnType $1 $2) == "int" ]]; then
        if [[ -n $3 && $3 != "null" && $(isNumber $3) -eq 0 ]]; then
            print "Error: $2 must be an integer" "white" "red"
            echo 0
            return
        fi
    elif [[ -n $3 && $3 != "null" && $(getColumnType $1 $2) == "varchar" ]]; then
        if [[ $(containsColon $3) -eq 1  && ! -z $3 ]]; then
            print "Error: $2 must not contain :" "white" "red"
            echo 0
            return
        fi
    fi

    # fifth check: check data length
    if [[ $(getColumnSize $1 $2) -lt ${#3} ]]; then
        print "Error: $2 must not exceed $(getColumnSize $1 $2) characters" "white" "red"
        echo 0
        return
    fi

    echo 1
}

# function to delete a column from the metadata
# $1: table name
# $2: column name
function deleteColumnFromMetadata() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        print "Error: Metadata file for database $CURRENT_DB_NAME does not exist" "white" "red"
        return
    fi

    # remove the column name , type, size and constraints from the metadata
    awk -v table_name="$1" -v column_name="$2" '
    BEGIN {FS=":"; OFS=":"}
    {
        if ($1 == table_name) {
            for (i = 2; i <= NF; i+=4) {
                if ($i == column_name) {
                    for (j = i; j <= NF-4; j++) {
                        $j = $(j+4)
                    }
                    NF -= 4
                    break
                }
            }
            print $0
        }
    }
    ' "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" > "$CURRENT_DB_PATH/.$CURRENT_DB_NAME"
    print "Column $2 dropped from metadata successfully." "white" "green"
}

# function to add a column to the metadata
# $1: table name
# $2: column name
# $3: column type
# $4: column size
# $5: column constraints
function addColumnToMetadata() {
    # Check if the metadata file exists
    if [[ ! -f "iti/.iti" ]]; then
        print "Error: Metadata file for database $CURRENT_DB_NAME does not exist" "white" "red"
        return
    fi

    awk -v table_name="$1" -v column_name="$2" -v column_type="$3" -v column_size="$4" -v column_constraints="$5" '
    BEGIN {FS=":"; OFS=":"}
    {
        if ($1 == table_name) {
            $0 = $0 ":" column_name ":" column_type ":" column_size ":" column_constraints
        }
        print $0
    }
    print "Column $2 added to metadata successfully." "white" "green"
    }' "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" > "$CURRENT_DB_PATH/.$CURRENT_DB_NAME"
    print "Column $2 added to metadata successfully." "white" "green"
}

# function to rename column
# $1: table name
# $2: old column name
# $3: new column name
function renameColumn() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        print "Error: Metadata file for database $CURRENT_DB_NAME does not exist" "white" "red"
        return
    fi

    awk -v table_name="$1" -v old_column_name="$2" -v new_column_name="$3" '
    BEGIN {FS=":"; OFS=":"}
    {
        if ($1 == table_name) {
            for (i = 2; i <= NF; i+=4) {
                if ($i == old_column_name) {
                    $i = new_column_name
                    break
                }
            }
        }
        print $0
    }' "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" > "$CURRENT_DB_PATH/.$CURRENT_DB_NAME"
    print "Column $2 renamed to $3 successfully." "white" "green"
}

# function to modify column data type
# $1: table name
# $2: column name
# $3: new column type
function modifyColumnType() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        print "Error: Metadata file for database $CURRENT_DB_NAME does not exist" "white" "red"
        return
    fi

    awk -v table_name="$1" -v column_name="$2" -v new_column_type="$3" '
    BEGIN {FS=":"; OFS=":"}
    {
        if ($1 == table_name) {
            for (i = 2; i <= NF; i+=4) {
                if ($i == column_name) {
                    $(i+1) = new_column_type
                    break
                }
            }
        }
        print $0
    }' "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" > "$CURRENT_DB_PATH/.$CURRENT_DB_NAME"
    print "Column $2 data type modified to $3 successfully." "white" "green"
}

# function to modify column size
# $1: table name
# $2: column name
# $3: new column size
function modifyColumnSize() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        print "Error: Metadata file for database $CURRENT_DB_NAME does not exist" "white" "red"
        return
    fi

    awk -v table_name="$1" -v column_name="$2" -v new_column_size="$3" '
    BEGIN {FS=":"; OFS=":"}
    {
        if ($1 == table_name) {
            for (i = 2; i <= NF; i+=4) {
                if ($i == column_name) {
                    $(i+2) = new_column_size
                    break
                }
            }
        }
        print $0
    }' "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" > "$CURRENT_DB_PATH/.$CURRENT_DB_NAME"
    print "Column $2 size modified to $3 successfully." "white" "green"
}

# function to modify column constraints
# $1: table name
# $2: column name
# $3: contraint to modify (pk,null,uniqe)
# $4: new value for the constraint
function modifyColumnConstraint() {
    # Check if the metadata file exists
    if [[ ! -f "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" ]]; then
        print "Error: Metadata file for database $CURRENT_DB_NAME does not exist" "white" "red"
        return
    fi

    awk -v table_name="$1" -v column_name="$2" -v constraint="$3" -v new_value="$4" '
    BEGIN {FS=":"; OFS=":"}
    {
        if ($1 == table_name) {
            for (i = 2; i <= NF; i+=4) {
                if ($i == column_name) {
                    if (constraint == "pk") 
                    {
                        substr($i+3, 1, 1) = new_value
                    } 
                    else if (constraint == "null") 
                    {
                        substr($i+3, 2, 1) = new_value
                    } 
                    else if (constraint == "unique") {
                        substr($i+3, 3, 1)= new_value
                    }
                    break
                }
            }
        }
        print $0
    }' "$CURRENT_DB_PATH/.$CURRENT_DB_NAME" > "$CURRENT_DB_PATH/.$CURRENT_DB_NAME"
    print "Column $2 $3 modified to $4 successfully." "white" "green"
}