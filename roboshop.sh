#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z026504233SANXQ4H9YRL"
ROUTE53_DOMAIN="devopstech.shop"
# Check if MySQL is installed
USERID=$(id -u)

#check if the user is root
if [ "$USERID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

if [ $# -lt 2 ]; then
    echo "Error: Atleast 2 arguments are required."
    echo "Usage: $0 [create/delete] [instance1 instance2 ...]"
    exit 1
fi



