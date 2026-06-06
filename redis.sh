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
    if [ $1 -ne 0 ]; then
        echo -e "$R ERROR:: $2 $N"
        exit 1
    else
        echo -e "$G SUCCESS:: $2 $N"
    fi
}

dnf module disable redis -y
dnf module enable redis:7 -y
dnf install redis -y &>> $LOG_FILE
validate $? "Redis installed"

# sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf
# sed -i -e 's/protected-mode yes/protected-mode no/g' /etc/redis.conf

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e 's/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf &>> $LOG_FILE
validate $? "Redis configuration updated"

systemctl enable redis &>> $LOG_FILE
systemctl start redis &>> $LOG_FILE
validate $? "Redis started"