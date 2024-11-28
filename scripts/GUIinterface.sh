#!/usr/bin/bash

##################################################################
# This file contains scripts for interacting with (electron) GUI
##################################################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# echo "SCRIPT_DIR: $SCRIPT_DIR"
source $SCRIPT_DIR/database.sh
source $SCRIPT_DIR/helper.sh
source $SCRIPT_DIR/metadata.sh
source $SCRIPT_DIR/sqlhandler.sh
source $SCRIPT_DIR/sqlparser.sh
source $SCRIPT_DIR/table.sh

if [[ $1 == "--listDatabases" ]]; then
    listDatabases
elif [[ $1 == "--listTables" ]]; then
    listTables
elif [[ $1 == "--listColumns" ]]; then
    # Check if the metadata file exists
    if [[ ! -f ".$2" ]]; then
        print "Error: Metadata file for database $2 does not exist" "white" "red"
    fi

    # Initialize an empty array for column names
    column_names=()

    # Use awk to search for the table name and extract column names
    column_names_str=$(awk -v table_name="$3" '
    BEGIN {FS=":"}
    {
        if ($1 == table_name) {
            for (i = 2; i <= NF; i+=4) {
                printf "%s ", $i
            }
        }
    }
    ' ".$2")

    # Convert the space-separated string to an array
    IFS=' ' read -r -a column_names <<< "$column_names_str"

    # Print the array elements
    echo "${column_names[@]}"
elif [[ $1 == "--sql" ]]; then
    parseQuery $2
else
    print "Error: Invalid command" "white" "red"
fi