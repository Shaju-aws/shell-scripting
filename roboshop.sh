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

ACTION=$1
shift

if [ "$ACTION" != "create" ] && [ "$ACTION" != "delete" ]; then
    echo "Error: Invalid action. Use 'create' or 'delete'."
    echo "Usage: $0 [create/delete] [instance1 instance2 ...]"
    exit 1
fi

get_instanceID() {
    aws ec2 describe-instances --filters "Name=tag:Name,Values=Roboshop-$name" "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].InstanceId" --output text
}

# aws ec2 run-instances \
#    --image-id $AMI_ID \ # Replace with your desired AMI ID
#    --count 1 \
#    --instance-type t2.micro \
#    --security-groups MySecurityGroup \
#    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyEC2Instance}]'

