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
elif [[ $1 == "--connectToDatabase" ]]; then
    connectToDatabase $2
elif [[ $1 == "--listTables" ]]; then
    listTables
elif [[ $1 == "--listColumns" ]]; then
    getColumnNames $2
elif [[ $1 == "--sql" ]]; then
    parseQuery $2
else
    print "Error: Invalid command" "white" "red"
fi