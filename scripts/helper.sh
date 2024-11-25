#!/usr/bin/bash

################################################################################
#
# This file contains helper functions that can be used in other scripts         
#
################################################################################

# helper function that takes a string and check if it is alphanumeric or not
# returns 1 if it is alphanumeric, 0 otherwise
function isAlphaNumeric() {
    if [[ $1 =~ ^[a-zA-Z0-9]+$ ]]; then
        echo 1
    else
        echo 0
    fi
}

# helper function that takes a file name and directory and checks 
# if it exists or not in the given directory
# if no given directory, it checks in the current directory
# returns 1 if it exists, 0 otherwise
function fileExists() {
    if [ -z "$2" ]; then
        if [ -e "$1" ]; then
            echo 1
        else
            echo 0
        fi
    else
        if [ -e "$2/$1" ]; then
            echo 1
        else
            echo 0
        fi
    fi
}


# helper function that takes a dir name and another dir and checks 
# if it exists or not in the given directory
# if no given directory, it checks in the current directory
# returns 1 if it exists, 0 otherwise
function dirExists() {
    if [ -z "$2" ]; then
        if [ -d "$1" ]; then
            echo 1
        else
            echo 0
        fi
    else
        if [ -d "$2/$1" ]; then
            echo 1
        else
            echo 0
        fi
    fi
}

# helper function that takes a name of file or directory and checks its length
# returns 1 if it is greater than 255, 0 otherwise
function isNameTooLong() {
    if [ ${#1} -gt 255 ]; then
        echo 1
    else
        echo 0
    fi
}


# helper function that takes a path and checks its length 
# if the path is not given, it checks the current directory
# returns 1 if it is greater than 4096, 0 otherwise
function isPathTooLong() {
    if [ -z "$1" ]; then
        if [ ${#PWD} -gt 4096 ]; then
            echo 1
        else
            echo 0
        fi
    else
        if [ ${#1} -gt 4096 ]; then
            echo 1
        else
            echo 0
        fi
    fi
}

# helper function that take a path and checks for its read permission
# if the path is not given, it checks the current directory
# returns 1 if it has read permission, 0 otherwise
function hasReadPermission() {
    if [ -z "$1" ]; then
        if [ -r "$PWD" ]; then
            echo 1
        else
            echo 0
        fi
    else
        if [ -r "$1" ]; then
            echo 1
        else
            echo 0
        fi
    fi
}

# helper function that take a path and checks for its write permission
# if the path is not given, it checks the current directory
# returns 1 if it has write permission, 0 otherwise
function hasWritePermission() {
    if [ -z "$1" ]; then
        if [ -w "$PWD" ]; then
            echo 1
        else
            echo 0
        fi
    else
        if [ -w "$1" ]; then
            echo 1
        else
            echo 0
        fi
    fi
}

# helper function that take a path and checks for its execute permission
# if the path is not given, it checks the current directory
# returns 1 if it has execute permission, 0 otherwise
function hasExecutePermission() {
    if [ -z "$1" ]; then
        if [ -x "$PWD" ]; then
            echo 1
        else
            echo 0
        fi
    else
        if [ -x "$1" ]; then
            echo 1
        else
            echo 0
        fi
    fi
}


# helper function that takes the table path and the column name and checks if the column contains duplicates or not
# $1: table path
# $2: column index
# returns 1 if the column contains duplicates, 0 otherwise
function checkDublicates (){
    echo $(awk -v col="$2" 'BEGIN { FS=":"; flag =0;} { if ($col in seen) {
            print 1
            flag=1
            exit

            } else {
                seen[$col] = 1;
            }} END { if (!flag)print 0}' "$1")
}