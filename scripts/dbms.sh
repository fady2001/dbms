#!/usr/bin/bash

################################################################################
#
#  This file contains main function that run all the scripts
#
################################################################################

# Load functions from database.sh
source ./database.sh
source ./table.sh
source ./sqlparser.sh
source ./sqlhandler.sh
source ./helper.sh
source ./metadata.sh

# flag to check if the database is connected
connected=1
# flag to check if the application should exit
exit=0

# create an environment variable to store the path of the current database
export CURRENT_DB_PATH=""
export CURRENT_DB_NAME=""

# Function to run the menu mode
run_menu_mode() {
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
                        read -n 1 -s -r -p "Press any key to continue . . ."
                        clear
                        break
                        ;;
                    "Drop a database")
                        read -p "Enter the database name: " dbName
                        dropDatabase $dbName
                        ;;
                    "Exit")
                        print "Are you sure you want to exit? (y/n)" "black" "yellow"
                        read -n 1 -r -s -p "" REPLY
                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                            print "Goodbye!" "black" "green"
                            exit=1
                        fi
                        break
                        ;;
                    *) print "Error: invalid option $REPLY" "white" "red";;
                esac
                # press any key to continue
                read -n 1 -s -r -p "Press any key to continue . . ."
                clear
                break
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
                        deleteFromTable "$tableName"
                        ;;
                    "Update Table")
                        read -p "Enter the table name: " tableName
                        updateTable $tableName
                        ;;
                    "Exit")
                        connected=1
                        cd ..
                        clear
                        break
                        ;;
                    *) print "Error: invalid option $REPLY" "white" "red";;
                esac
                read -n 1 -s -r -p "Press any key to continue . . ."
                clear
                break
            done
        fi
    done
}

# Function to run the SQL mode
run_sql_mode() {
    while [[ exit -ne 1 ]]; do
        read -p "sql> " sqlCommand
        case $sqlCommand in
            "exit")
                exit=1
                ;;
            *)
                parseQuery "$sqlCommand"
                ;;
        esac
    done
}

# Main script execution
if [[ $1 == "--menu" || -z $1 ]]; then
    run_menu_mode
elif [[ $1 == "--sql" ]]; then
    run_sql_mode
elif [[ $1 == "--run" ]]; then
    parseQuery "$2"
elif [[ $1 == "--list" ]]; then
    listDatabases
elif [[ $1 == "--help" ]]; then
    echo "Usage: dbms.sh [OPTION] [SQL COMMAND]"
    echo "Run a database management system"
    echo ""
    echo "Options:"
    echo "  --menu  Run the database management system in menu mode"
    echo "  --sql   Run the database management system in SQL mode"
    echo "  --run   Run a specific SQL command"
    echo "  --list  List all databases"
    echo "  --help  Display this help message"
else
    echo "Invalid option. Use --menu or --sql."
fi