#!/bin/bash
LOG_FOLDER="/var/log/roboshop"
mkdir -p $LOG_FOLDER
chmod 755 -R $LOG_FOLDER
chown ec2-user:ec2-user -R $LOG_FOLDER
LOG_FILE="$LOG_FOLDER/$0.log"
SCRIPT_DIR=$PWD

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

dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs -y &>> $LOG_FILE
validate $? "NodeJS installed"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "Roboshop user added"

mkdir -p /app &>> $LOG_FILE
validate $? "App directory created"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip 
cd /app 
unzip /tmp/cart.zip &>> $LOG_FILE
validate $? "Cart code downloaded and extracted"

cd /app
npm install 
validate $? "Cart dependencies installed"

cp ${SCRIPT_DIR}/cart.service /etc/systemd/system/cart.service &>> $LOG_FILE
validate $? "Cart systemd service file copied"

systemctl daemon-reload &>> $LOG_FILE
systemctl enable cart &>> $LOG_FILE
systemctl start cart &>> $LOG_FILE
validate $? "Cart service started"