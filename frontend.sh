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

dnf module disable nginx -y
dnf module enable nginx:1.24 -y
dnf install nginx -y
validate $? "Nginx installed"

systemctl enable nginx 
systemctl start nginx 
validate $? "Nginx started"

rm -rf /usr/share/nginx/html/* 
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
validate $? "Frontend code downloaded and extracted"

rm /etc/nginx/nginx.conf
cp nginx.conf /etc/nginx/nginx.conf
validate $? "Nginx configuration file copied"
systemctl restart nginx
validate $? "Nginx restarted"
