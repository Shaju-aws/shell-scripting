#!/bin/bash
LOG_FOLDER="/var/log/roboshop"
mkdir -p $LOG_FOLDER
chmod 755 -R $LOG_FOLDER
chown ec2-user:ec2-user -R $LOG_FOLDER
LOG_FILE="$LOG_FOLDER/$0.log"

USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

if [ $USER_ID -ne 0 ]; then
    echo -e "$R ERROR:: You must be root to run this script $N"
    exit 1
fi

validate() {
    if [$1 -ne 0 ]; then
        echo -e "$R ERROR:: $2 $N"
        exit 1
    else
        echo -e "$G SUCCESS:: $2 $N"
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE
validate $? "MongoDB Repo file copied"

dnf install -y mongodb-org &>> $LOG_FILE
systmctl enable mongod &>> $LOG_FILE
systemctl start mongod &>> $LOG_FILE
validate $? "MongoDB installed and started"

sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
systemctl restart mongod &>> $LOG_FILE
validate $? "MongoDB restarted with new configuration"