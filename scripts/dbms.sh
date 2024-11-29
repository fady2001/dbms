#!/usr/bin/bash

################################################################################
#
#  This file contains main function that run all the scripts
#
################################################################################

# Load functions from database.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/database.sh
source $SCRIPT_DIR/helper.sh
source $SCRIPT_DIR/metadata.sh
source $SCRIPT_DIR/sqlhandler.sh
source $SCRIPT_DIR/sqlparser.sh
source $SCRIPT_DIR/table.sh

# flag to check if the database is connected
connected=1
# flag to check if the application should exit
exit=0

# create an environment variable to store the path of the current database
export CURRENT_DB_PATH=""
export CURRENT_DB_NAME=""

# function for alter table
# FILE: table.sh

# # Function to alter a table
# alterTable() {
#     clear
#     local tableName=$1
#     if [[ -z $tableName ]]; then
#         print "Table name cannot be empty." "white" "red"
#         return 1
#     fi

#     if [[ ! -f "$CURRENT_DB_PATH/$tableName" ]]; then
#         print "Table '$tableName' does not exist." "white" "red"
#         return 1
#     fi

#     echo "Select an option to alter the table:"
#     select option in "Add Column" "Drop Column" "Rename Column" "Change Data Type" "Change Data Length" "Add Constraint" "Remove Constraint" "Exit"; do
#         case $option in
#             "Add Column")
#                 read -p "Enter the column name: " columnName
#                 # check if the column name is alphanumeric
#                 if [[ $(isAlphaNumeric $columnName) -eq 0 ]]; then
#                     print "Error: Column name should be alphanumeric" "white" "red"
#                     return
#                 fi

#                 # check if the column already exists
#                 if [[ $(getColumnIndex $tableName $columnName) -ne -1 ]]; then
#                     print "Error: Column already exists" "white" "red"
#                     return
#                 fi
                
#                 read -p "Enter the column type: " columnType
#                 if [[ ! $columnType =~ ^([iI][nN][tT]|[vV][aA][rR][cC][hH][aA][rR])$ ]]; then
#                     print "Error: type is not supported" "white" "red"
#                     return
#                 fi
                
#                 read -p "Enter the column length: " columnLength
#                 if [[ $(isNumber $columnLength) -eq 0 || $columnLength -eq 0 || $columnLength =~ ^- ]]; then
#                     print "Error: unvalid column length" "white" "red"
#                     return
#                 fi
                
#                 read -p "Enter the column constraint primary key or not null or unique: " columnConstraint
#                 # handling the constraints
#                 constraint=""
#                 # handling primary key constraint
#                 if [[ $columnConstraint =~ [pP][rR][iI][mM][aA][rR][yY] ]]; then
#                     constraint+='y'
#                 else
#                     constraint+='n'
#                 fi
#                 # handling not null constraint
#                 if [[ $columnConstraint =~ [nN][oO][tT][[:space:]]+[nN][uU][lL][lL] ]]; then 
#                     constraint+='y'
#                 else
#                     constraint+='n'
#                 fi
#                 # handling unique constraint
#                 if [[ $columnConstraint =~ [uU][nN][iI][qQ][uU][eE] ]]; then
#                     constraint+='y'
#                 else
#                     constraint+='n'
#                 fi
#                 pk=$(getPrimaryKey $tableName)
#                 if [[ $pk -ne -1 && ${5:0:1} == "y" ]]; then
#                     print "Error: column $pk is the primary key for $tableName table" "white" "red"
#                     return
#                 fi
                
#                 read -p "Enter default value if exist: " default
#                 if [[ ${5:1:1} == "y" && -z $default ]]; then
#                     print "Error: need a default value" "white" "red"
#                     return
#                 fi

#                 if [[ ${5:2:1} == "y" && ! -z $default ]]; then
#                     print "warning: Unique column cannot have default value" "white" "yellow"
#                     default=""
#                 fi

#                 if [[ ! -z $default && $(isNumber $default) -eq 0 && $columnType =~ ^([iI][nN][tT])$ ]];then
#                     print "Error: default value and column don't have the same type" "white" "red"
#                     return
#                 fi

#                 if [[ $(alterTableAddColumn $tableName $columnName $columnType $columnLength $constraint $default) -eq -1 ]]; then
#                     return
#                 fi
#                 ;;
#             "Drop Column")
#                 read -p "Enter the column name: " columnName
#                 # check if the column name is alphanumeric
#                 if [[ $(isAlphaNumeric $columnName) -eq 0 ]]; then
#                     print "Error: Column name should be alphanumeric" "white" "red"
#                     return
#                 fi

#                 # check if the column already exists
#                 if [[ ! $(getColumnIndex $tableName $columnName) -ne -1 ]]; then
#                     print "Error: Column doesn't exist" "white" "red"
#                     return
#                 fi

#                 if [[ $(deleteColumnFromMetadata $tableName $columnName) -eq -1 ]]; then
#                     return
#                 fi
#                 print "Dropping column '$columnName' from table '$tableName'."
#                 # Example: sed -i "/$columnName/d" "$CURRENT_DB_PATH/$tableName"
#                 ;;
#             "Rename Column")
#                 read -p "Enter the current column name: " currentColumnName
#                 # check if the column name is alphanumeric
#                 if [[ $(isAlphaNumeric $currentColumnName) -eq 0 ]]; then
#                     print "Error: currentColumnName name should be alphanumeric" "white" "red"
#                     return
#                 fi

#                 # check if the column already exists
#                 if [[ ! $(getColumnIndex $tableName $currentColumnName) -ne -1 ]]; then
#                     print "Error: Column doesn't exist" "white" "red"
#                     return
#                 fi
#                 read -p "Enter the new column name: " newColumnName
#                 if [[ $(isAlphaNumeric $newColumnName) -eq 0 ]]; then
#                     print "Error: newColumnName name should be alphanumeric" "white" "red"
#                     return
#                 fi
#                 # Add logic to rename the column in the table
#                 renameColumn $tableName $currentColumnName $newColumnName
#                 ;;
#             "Change Data Type")
#                 read -p "Enter the column name: " columnName
#                 # check if the column name is alphanumeric
#                 if [[ $(isAlphaNumeric $columnName) -eq 0 ]]; then
#                     print "Error: Column name should be alphanumeric" "white" "red"
#                     return
#                 fi

#                 # check if the column already exists
#                 if [[ ! $(getColumnIndex $tableName $columnName) -ne -1 ]]; then
#                     print "Error: Column doesn't exist" "white" "red"
#                     return
#                 fi
                
#                 read -p "Enter the new data type: " newDataType
#                 if [[ $(isStringColumn $tableName $columnName) -eq 0 && $newDataType =~ ^([iI][nN][tT])$ ]]; then
#                     print "Error: column $columnName is a string column" "white" "red"
#                     return
#                 fi
#                 # Add logic to change the data type of the column
#                 modifyColumnType $tableName $columnName $newDataType
#                 ;;
#             "Change Data Length")
#                 read -p "Enter the column name: " columnName
#                 # check if the column name is alphanumeric
#                 if [[ $(isAlphaNumeric $columnName) -eq 0 ]]; then
#                     print "Error: Column name should be alphanumeric" "white" "red"
#                     return
#                 fi

#                 # check if the column already exists
#                 if [[ ! $(getColumnIndex $tableName $columnName) -ne -1 ]]; then
#                     print "Error: Column doesn't exist" "white" "red"
#                     return
#                 fi
                
#                 read -p "Enter the column length: " columnLength
#                 if [[ $(isNumber $columnLength) -eq 0 || $columnLength -eq 0 || $columnLength =~ ^- ]]; then
#                     print "Error: unvalid column length" "white" "red"
#                     return
#                 fi
#                 if [[ $(isLengthLessThanData $tableName $columnName $columnLength) -eq 0 ]]; then
#                     print "Error: column length is less than the data" "white" "red"
#                     return
#                 fi
                
#                 modifyColumnSize $tableName $columnName $columnLength
#                 ;;
#             "Add Constraint")
#                 read -p "Enter the column name: " columnName
#                 if [[ $(isAlphaNumeric $columnName) -eq 0 ]]; then
#                     print "Error: Column name should be alphanumeric" "white" "red"
#                     return
#                 fi
#                 read -p "Enter a constraint primary key or not null or unique: " columnConstraint
#                 # handling primary key constraint
#                 if [[ $columnConstraint =~ [pP][rR][iI][mM][aA][rR][yY] ]]; then
#                     pk=$(getPrimaryKey $tableName)
#                     if [[ $pk -ne -1  ]]; then
#                         print "Error: column $pk is the primary key for $tableName table" "white" "red"
#                         return
#                     fi
#                     $(modifyColumnConstraint $tableName $columnName "pk" "y")
#                 fi
#                 # handling not null constraint
#                 if [[ $columnConstraint =~ [nN][oO][tT][[:space:]]+[nN][uU][lL][lL] ]]; then 
#                     $(modifyColumnConstraint $tableName $columnName "null" "y")
#                 fi
#                 # handling unique constraint
#                 if [[ $columnConstraint =~ [uU][nN][iI][qQ][uU][eE] ]]; then
#                     $(modifyColumnConstraint $tableName $columnName "unique" "y")
#                 fi
#                 ;;
#             "Remove Constraint")
#                 read -p "remove the column constraint primary key or not null or unique: " columnConstraint
#                 # handling primary key constraint
#                 if [[ $columnConstraint =~ [pP][rR][iI][mM][aA][rR][yY] ]]; then
#                     $(modifyColumnConstraint $tableName $columnName "pk" "n")
#                 fi
#                 # handling not null constraint
#                 if [[ $columnConstraint =~ [nN][oO][tT][[:space:]]+[nN][uU][lL][lL] ]]; then 
#                     $(modifyColumnConstraint $tableName $columnName "null" "n")
#                 fi
#                 # handling unique constraint
#                 if [[ $columnConstraint =~ [uU][nN][iI][qQ][uU][eE] ]]; then
#                     $(modifyColumnConstraint $tableName $columnName "unique" "n")
#                 fi
#                 ;;
#             "Exit")
#                 print "Are you sure you want to exit? (y/n)" "black" "yellow"
#                 read -n 1 -r -s -p "" REPLY
#                 if [[ $REPLY =~ ^[Yy]$ ]]; then
#                     break
#                 fi
#                 ;;
#             *)
#                 echo "Invalid option."
#                 ;;
#         esac
#     done
# }

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
            select option in  "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Alter Table" "Exit"
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
                    "Alter Table")
                        read -p "Enter the table name: " tableName
                        alterTable $tableName
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
elif [[ $1 == "--help" ]]; then
    echo "Usage: dbms.sh [OPTION] [SQL COMMAND]"
    echo "Run a database management system"
    echo ""
    echo "Options:"
    echo "  --menu  Run the database management system in menu mode"
    echo "  --sql   Run the database management system in SQL mode"
    echo "  --run   Run a specific SQL command"
    echo "  --help  Display this help message"
else
    echo "Invalid option. Use --menu or --sql."
fi

