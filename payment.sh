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

dnf install python3 gcc python3-devel -y &>> $LOG_FILE
validate $? "Python3 and dependencies installed"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "Roboshop user added"

mkdir /app 
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
cd /app 
unzip /tmp/payment.zip &>> $LOG_FILE
validate $? "Payment code downloaded and extracted"

cd /app 
pip3 install -r requirements.txt &>> $LOG_FILE
validate $? "Payment dependencies installed"

cp payment.service /etc/systemd/system/payment.service &>> $LOG_FILE
validate $? "Payment systemd service file copied"   

systemctl daemon-reload &>> $LOG_FILE
systemctl enable payment &>> $LOG_FILE
systemctl start payment &>> $LOG_FILE
validate $? "Payment service started"