#!/bin/bash
# Installing Moodle
# Pre-reqs: AMP
# 1. Apache
# 2. Mysql
# 3. PHP

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Installing other linux dependencies
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
sudo apt -y install php8.1
sudo apt -y install apache2
sudo apt -y install mysql-server
sudo apt -y install php-cli

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Setting Up mysql
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
PWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16 ; echo '')
sudo systemctl stop mysql
cat << EOF  > /tmp/temp.cnf
[mysqld]
skip-grant-tables
skip-networking
EOF

sudo cp /tmp/temp.cnf /etc/mysql/mysql.conf.d/

cat << EOF > /tmp/init.sql
FLUSH PRIVILEGES;
CREATE USER 'main'@'localhost' IDENTIFIED BY '$PWORD';
CREATE DATABASE main;
GRANT ALL PRIVILEGES ON main.* TO 'main'@'localhost';
EOF

sudo systemctl start mysql

sleep 10

sudo mysql -u root < /tmp/init.sql

sudo systemctl stop mysql

sudo mv /etc/mysql/mysql.conf.d/temp.cnf /tmp/temp.cnf.bkp

sudo systemctl start mysql

sleep 10

