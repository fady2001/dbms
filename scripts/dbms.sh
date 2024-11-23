#!/usr/bin/bash

################################################################################
#
#  This file contains main function that run all the scripts
#
################################################################################

# Load functions from database.sh
source ./database.sh


# Main function that runs the application
PS3="Please select an option: "

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
            ;;
        "Drop a database")
            read -p "Enter the database name: " dbName
            dropDatabase $dbName
            ;;
        "Exit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
