#!/usr/bin/bash

################################################################################
#
#  This file contains main function that run all the scripts
#
################################################################################

# Load functions from database.sh
source ./database.sh
source ./table.sh


# flag to check if the database is connected
connected=1
# flag to check if the application should exit
exit=0

# Main function that runs the application
PS3="Please select an option: "
while [[ exit -ne 1 ]]; do
    if [[ connected -ne 0 ]]; then
        select option in  "create a database" "list databases" "connect to a database" "Drop a database" "Exit"
        do
            case $option in
                "create a database")
                    read -p "Enter the database name: " dbName
                    createDatabase $dbName
                    ;;
                "list databases")
                    listDatabases
                    ;;
                "connect to a database")
                    read -p "Enter the database name: " dbName
                    connectToDatabase $dbName
                    connected=$?
                    break
                    ;;
                "Drop a database")
                    read -p "Enter the database name: " dbName
                    dropDatabase $dbName
                    ;;
                "Exit")
                    exit=1
                    break
                    ;;
                *) echo "invalid option $REPLY";;
            esac
        done

    else
        select option in  "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Exit"
        do
            case $option in
                "Create Table")
                    read -p "Enter the table name: " tableName
                    createTable $tableName
                    ;;
                "List Tables")
                    listTables
                    ;;
                "Drop Table")
                    read -p "Enter the table name: " tableName
                    dropTable $tableName
                    ;;
                "Insert into Table")
                    read -p "Enter the table name: " tableName
                    insertIntoTable $tableName
                    ;;
                "Select From Table")
                    read -p "Enter the table name: " tableName
                    selectFromTable $tableName
                    ;;
                "Delete From Table")
                    read -p "Enter the table name: " tableName
                    deleteFromTable $tableName
                    ;;
                "Update Table")
                    read -p "Enter the table name: " tableName
                    updateTable $tableName
                    ;;
                "Exit")
                    connected=1
                    break
                    ;;
                *) echo "invalid option $REPLY";;
            esac
        done
    fi
done