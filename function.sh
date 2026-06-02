#!/bin/bash
install_package () {
    package=$1
    dnf list installed $package
    if [ $? -eq 0 ]; then
        echo "$package is already installed skipping installation"
    else
        echo "$package is not installed, installing now"
        dnf install $package -y
        if [ $? -eq 0 ]; then
            echo "$package is installed"
        else
            echo "$package is failed to install"
            exit 1
        fi
    fi
}

install_package mysql
install_package httpd
install_package nginx
install_package netstat

