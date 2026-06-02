#!/bin/bash
# Check if MySQL is installed
dnf list installed mysql

if [ $? -eq 0 ]; then
    echo "mysql is alredy installed skipping installation"
else
    echo "mysql is not installed, installing now"
    dnf install mysql-server -y
    if [ $? -eq 0 ]; then
        echo "mysql is installed"
    else
        echo "mysql is failed to install"
        exit 1
        fi
fi
#     systemctl start mysqld
#     systemctl enable mysqld
# fi