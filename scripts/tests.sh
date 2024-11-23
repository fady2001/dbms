#!/usr/bin/bash

# Load the function from create.sh if it's in a different file
source ./helper.sh

# -------------------------------- test isAlphaNumeric -------------------------
echo ------------------- testing isAlphaNumeric -------------------
# test case 1
actual=$(isAlphaNumeric "hello")
expected=1  # "hello" is alphanumeric
if [ "$actual" == "$expected" ]; then
    echo "Test case 1 passed"
else
    echo "Test case 1 failed"
fi

# test case 2
actual=$(isAlphaNumeric "hello123")
expected=1  # "hello123" is alphanumeric
if [ "$actual" == "$expected" ]; then
    echo "Test case 2 passed"
else
    echo "Test case 2 failed"
fi

# test case 3
actual=$(isAlphaNumeric "hello@123")
expected=0  # "hello@123" is not alphanumeric due to '@'
if [ "$actual" == "$expected" ]; then
    echo "Test case 3 passed"
else
    echo "Test case 3 failed"
fi

# test case 4
actual=$(isAlphaNumeric "hello 123")
expected=0  # "hello 123" is not alphanumeric due to space
if [ "$actual" == "$expected" ]; then
    echo "Test case 4 passed"
else
    echo "Test case 4 failed"
fi

# test case 5
actual=$(isAlphaNumeric "hello123world ")
expected=0  # "hello123world " is not alphanumeric due to space
if [ "$actual" == "$expected" ]; then
    echo "Test case 5 passed"
else
    echo "Test case 5 failed"
fi

# test case 6
actual=$(isAlphaNumeric "hello123world")
expected=1  # "hello123world" is alphanumeric
if [ "$actual" == "$expected" ]; then
    echo "Test case 6 passed"
else
    echo "Test case 6 failed"
fi

# test case 7
actual=$(isAlphaNumeric "hello123world@")
expected=0  # "hello123world@" is not alphanumeric due to '@'
if [ "$actual" == "$expected" ]; then
    echo "Test case 7 passed"
else
    echo "Test case 7 failed"
fi

# test case 8
actual=$(isAlphaNumeric "hello123world@123")
expected=0  # "hello123world@123" is not alphanumeric due to '@'
if [ "$actual" == "$expected" ]; then
    echo "Test case 8 passed"
else
    echo "Test case 8 failed"
fi

# -------------------------------- test fileExists -------------------------
echo ------------------- testing fileExists -------------------
# test case 1
actual=$(fileExists "helper.sh")
expected=1  # "helper.sh" exists in the current directory
if [ "$actual" == "$expected" ]; then
    echo "Test case 1 passed"
else
    echo "Test case 1 failed"
fi

# test case 2
actual=$(fileExists "helper.sh" "tests")
expected=0  # "helper.sh" does not exist in the "tests" directory
if [ "$actual" == "$expected" ]; then
    echo "Test case 2 passed"
else
    echo "Test case 2 failed"
fi

# test case 3
actual=$(fileExists "test" "test_dir")
expected=1  # "test.sh" exists in the "test_dir" directory
if [ "$actual" == "$expected" ]; then
    echo "Test case 3 passed"
else
    echo "Test case 3 failed"
fi

# -------------------------------- test dirExists -------------------------
echo ------------------- testing dirExists -------------------
# test case 1
actual=$(dirExists "test_dir")
expected=1  # "test_dir" exists in the current directory
if [ "$actual" == "$expected" ]; then
    echo "Test case 1 passed"
else
    echo "Test case 1 failed"
fi

# test case 2
actual=$(dirExists "test_dir" "tests")
expected=0  # "test_dir" does not exist in the "tests" directory
if [ "$actual" == "$expected" ]; then
    echo "Test case 2 passed"
else
    echo "Test case 2 failed"
fi

# test case 3
actual=$(dirExists "dir1" "test_dir")
expected=1  # "dir1" exists in the "test_dir" directory
if [ "$actual" == "$expected" ]; then
    echo "Test case 3 passed"
else
    echo "Test case 3 failed"
fi

# -------------------------------- test isNameTooLong -------------------------
echo ------------------- testing isNameTooLong -------------------
# test case 1
actual=$(isNameTooLong "hello")
expected=0  # "hello" has length less than 255
if [ "$actual" == "$expected" ]; then
    echo "Test case 1 passed"
else
    echo "Test case 1 failed"
fi

# test case 2
actual=$(isNameTooLong "this_is_a_very_long_name_that_exceeds_the_limit_of_255_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_255_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_255_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_255_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_255_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_255_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_255_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_255_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_255_characters")
expected=1
if [ "$actual" == "$expected" ]; then
    echo "Test case 2 passed"
else
    echo "Test case 2 failed"
fi

#-------------------------------- test isPathTooLong -------------------------
echo ------------------- testing isPathTooLong -------------------
# test case 1
actual=$(isPathTooLong $PWD)
expected=0  # current directory path length is less than 4096
if [ "$actual" == "$expected" ]; then
    echo "Test case 1 passed"
else
    echo "Test case 1 failed"
fi

# test case 2
actual=$(isPathTooLong "/home/username/Downloads/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters/this_is_a_very_long_name_that_exceeds_the_limit_of_4096_characters")
expected=1  # path length is greater than 4096
if [ "$actual" == "$expected" ]; then
    echo "Test case 2 passed"
else
    echo "Test case 2 failed"
fi

#-------------------------------- test hasWritePermission -------------------------
echo ------------------- testing hasWritePermission -------------------
# test case 1
actual=$(hasWritePermission)
expected=1  # we have write permission in the current directory
if [ "$actual" == "$expected" ]; then
    echo "Test case 1 passed"
else
    echo "Test case 1 failed"
fi

# test case 2
actual=$(hasWritePermission "/root")
expected=0  # we do not have write permission in the "/root" directory
if [ "$actual" == "$expected" ]; then
    echo "Test case 2 passed"
else
    echo "Test case 2 failed"
fi

# test case 3 
actual=$(hasWritePermission "dbms.sh")
expected=1  # we have write permission in the "dbms.sh" file
if [ "$actual" == "$expected" ]; then
    echo "Test case 3 passed"
else
    echo "Test case 3 failed"
fi

# -------------------------------- test hasExecutePermission -------------------------
echo ------------------- testing hasExecutePermission -------------------
# test case 1
actual=$(hasExecutePermission)
expected=1  # we have execute permission in the current directory
if [ "$actual" == "$expected" ]; then
    echo "Test case 1 passed"
else
    echo "Test case 1 failed"
fi

# test case 2
actual=$(hasExecutePermission "/root")
expected=0  # we do not have execute permission in the "/root" directory
if [ "$actual" == "$expected" ]; then
    echo "Test case 2 passed"
else
    echo "Test case 2 failed"
fi

# test case 3
actual=$(hasExecutePermission "dbms.sh")
expected=1  # we have execute permission in the "dbms.sh" file
if [ "$actual" == "$expected" ]; then
    echo "Test case 3 passed"
else
    echo "Test case 3 failed"
fi

# -------------------------------- test hasReadPermission -------------------------
echo ------------------- testing hasReadPermission -------------------
# test case 1
actual=$(hasReadPermission)
expected=1  # we have read permission in the current directory
if [ "$actual" == "$expected" ]; then
    echo "Test case 1 passed"
else
    echo "Test case 1 failed"
fi

# test case 2
actual=$(hasReadPermission "/root")
expected=0  # we do not have read permission in the "/root" directory
if [ "$actual" == "$expected" ]; then
    echo "Test case 2 passed"
else
    echo "Test case 2 failed"
fi

# test case 3
actual=$(hasReadPermission "dbms.sh")
expected=1  # we have read permission in the "dbms.sh" file
if [ "$actual" == "$expected" ]; then
    echo "Test case 3 passed"
else
    echo "Test case 3 failed"
fi