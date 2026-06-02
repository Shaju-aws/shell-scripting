#!/bin/bash
# Check if MySQL is installed
dnf list installed mysql

if [ $? -eq 0 ]; then
    echo "mysql is alredy installed"
else
    echo "mysql is not installed, installing now"
    dnf install mysql-server -y
    systemctl start mysqld
    systemctl enable mysqld
fi