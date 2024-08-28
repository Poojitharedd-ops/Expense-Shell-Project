#!/bin/bash
LOGS_FOLDER="var/log/expense"
SCRIPT_NAME="$(echo $0 |cut -d "." -f1)
TIMESTAMP = $(date+%Y-%m-%d-%H-%M-%S )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP"
mkdir -p LOGS_FOLDER
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Please run this script with root priveleges $N" | tee -a $LOG_FILE
        exit 1
    fi
}
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

CHECK_ROOT
dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "mysql service installed or not?"
systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabled mysql server"
systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "started mysql server"
mysql -h mysql.poojitha.online -u root -pExpenseApp@1 -e 'show databases;
if [$? -ne 0]
then
echo " my sql setup is not done, setting up now" &>>$LOG_FILE
mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "set up root password"
else
 echo -e "MySQL root password is already setup...$Y SKIPPING $N" &>>$LOG_FILE
 fi

