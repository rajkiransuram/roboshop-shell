#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST=monogodb.srkdevcodes.cloud

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y 

VALIDATE $? "Disabling Nodejs" &>> $LOGFILE

dnf module enable nodejs:18 -y 

VALIDATE $? "Enabling NodeJs 18" &>> $LOGFILE

dnf install nodejs -y 

VALIDATE $? "Installing NodeJs 18"  &>> $LOGFILE

useradd roboshop 

VALIDATE $? "Creating roboshop User" &>> $LOGFILE

mkdir /app 

VALIDATE $? "Creaing /app Directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip  

VALIDATE $? "Downloading catalogue application" &>> $LOGFILE

cd /app

unzip /tmp/catalogue.zip

VALIDATE $? "Unzip catalogue " &>> $LOGFILE

npm install

VALIDATE $? "Installing dependencies" &>> $LOGFILE

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE $? "Copy catalogue.service file" &>> $LOGFILE

systemctl daemon-reload

VALIDATE $? "catalogue deamon realod" &>> $LOGFILE

systemctl enable catalogue

VALIDATE $? "catalogue enabling" &>> $LOGFILE

systemctl start catalogue

VALIDATE $? "start catalogue" &>> $LOGFILE

cp /home/centos/roboshop-shell/mongo.repo   /etc/yum.repos.d/mongo.repo

VALIDATE $? "coping mongodb repo" &>> $LOGFILE

dnf install mongodb-org-shell -y

VALIDATE $? "installing mongodb client" &>> $LOGFILE

mongo --host $MONGODB_HOST </app/schema/catalogue.js

VALIDATE $? "Loading catalogue data into mongoDb"



