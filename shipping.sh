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

dnf install maven -y &>> $LOG_FILE
validate $? "Maven installed"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "Roboshop user added"

mkdir -p /app &>> $LOG_FILE
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
cd /app 
unzip /tmp/shipping.zip &>> $LOG_FILE
validate $? "Shipping code downloaded and extracted"

cd /app
mvn clean package &>> $LOG_FILE
mv target/shipping-1.0.jar shipping.jar &>> $LOG_FILE
validate $? "Shipping application built"

cp shipping.service /etc/systemd/system/shipping.service &>> $LOG_FILE
validate $? "Shipping systemd service file copied"

systemctl daemon-reload &>> $LOG_FILE
systemctl enable shipping &>> $LOG_FILE
systemctl start shipping &>> $LOG_FILE
validate $? "Shipping service started"

dnf install mysql -y &>> $LOG_FILE
validate $? "MySQL client installed"

mysql -h mysql.devopstech.shop -uroot -pRoboShop@1 < /app/db/schema.sql &>> $LOG_FILE
validate $? "Shipping database schema initialized"

mysql -h mysql.devopstech.shop -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LOG_FILE
validate $? "Shipping database user created and permissions granted"

mysql -h mysql.devopstech.shop -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LOG_FILE
validate $? "Shipping database master data initialized"

systemctl restart shipping &>> $LOG_FILE
validate $? "Shipping service restarted after database initialization"