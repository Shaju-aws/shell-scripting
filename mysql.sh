#!/bin/bash

# Check if MySQL is installed
USERID=(id -u)

#check if the user is root
if [ $USERID -ne 0 ]; then
    echo "this schript must be run as root"
    exit 1
fi

