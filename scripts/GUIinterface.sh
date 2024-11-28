#!/usr/bin/bash

##################################################################
# This file contains scripts for interacting with (electron) GUI
##################################################################

if [[ $1 == "--listDatabases" ]]; then
    listDatabases
elif [[ $1 == "--connectDatabase" ]]; then
    connectDatabase $2
elif [[ $1 == "--listTables" ]]; then
    listTables
elif [[ $1 == "--listColumns" ]]; then
    getColumnNames $2
elif [[ $1 == "--sql" ]]; then
    parseQuery $2,.
else
    print "Invalid command" "white" "red"
fi