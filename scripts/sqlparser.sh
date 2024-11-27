#!/usr/bin/bash

################################################################################
#
# This file contains script to parse sql queries
#
################################################################################

# Load the helper functions
source ./helper.sh
source ./metadata.sh

# function that parse the sql query
# $1: sql query
function parseQuery() {
    # disable globbing (metacharacters)
    # because the query may contain special characters like "*"
    set -f
    # check if the query is empty
    if [[ -z $1 ]]; then
        print "Query is empty" "white" "red"
        return
    fi

    if [[ $1 =~ ^[[:space:]]*[sS][eE][lL][eE][cC][tT] ]]; then
        columns=$(echo $1 | grep -ioP '(?<=select ).*(?= from)')
        table=$(echo $1 | grep -ioP '(?<=from )[^ ]+(?= where|$)')
        conditions=$(echo $1 | grep -ioP '(?<=where ).*(?=[$;])')
        echo $columns
        echo $table
        echo $conditions
    elif [[ $1 =~ ^[[:space:]]*[dD][eE][lL][eE][tT][eE] ]]; then
        table=$(echo $1 | grep -ioP '(?<=from )[^ ]+(?= where|$)')
        conditions=$(echo $1 | grep -ioP '(?<=where ).*(?=[$;])')
        echo $table
        echo $conditions
        return
    elif [[ $1 =~ ^[[:space:]]*[uU][pP][dD][aA][tT][eE] ]]; then
        echo "Update query"
        table=$(echo $1 | grep -ioP '(?<=update )[^ ]+(?= set)')
        set=$(echo $1 | grep -ioP '(?<=set ).*(?= where)')
        conditions=$(echo $1 | grep -ioP '(?<=where ).*(?=[$;])')
        echo $table
        echo $set
        echo $conditions
        return
    elif [[ $1 =~ ^[[:space:]]*[iI][nN][sS][eE][rR][tT] ]]; then
        echo "Insert query"
        table=$(echo $1 | grep -ioP '(?<=into )[^ ]+(?= \(| values)')
        columns=$(echo $1 | grep -ioP '(?<=\().*(?=\) values)')
        values=$(echo $1 | grep -ioP '(?<=values ).*(?=[$;])')
        
        echo $table
        echo $values
        return
    else
        print "Invalid query" "white" "red"
        return
    fi
    set +f
}

parseQuery "    
    insert into emp (id, name, salary) values (2, 'ali', 2000);

"