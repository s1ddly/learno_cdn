#!/bin/bash
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Bootstrap script for the LearnAi website
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Installing/enabling ssh
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
sudo apt update
sudo apt install openssh-server
sudo systemctl enable ssh
sudo ufw allow ssh

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Installing other linux dependencies
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
sudo apt install php8.1
sudo apt install apache2
sudo apt install mysql-server
sudo apt install php-cli
sudo apt install php-xml
sudo apt install php-common
sudo apt install php-curl
sudo apt install php8.1-cli
sudo apt install php8.1-common
sudo apt install php8.1-curl
sudo apt install php8.1-mysql
sudo apt install php8.1-opcache
sudo apt install php8.1-readline
sudo apt install php8.1-xml
sudo apt install curl

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Installing Composer
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
sudo service apache2 restart

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Setting Up mysql
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
sudo systemctl stop mysql
sudo cat << EOF  > /etc/mysql/temp.cnf
[mysqld]
skip-grant-tables
skip-networking
EOF

cat << EOF > /tmp/init.sql
CREATE USER 'main'@'localhost';
CREATE DATABASE main;
GRANT ALL PRIVILEGES ON main.* TO 'main'@'localhost';
EOF

sudo systemctl start mysql

sudo mysql -u root < /tmp/init.sql

sudo systemctl stop mysql

sudo mv /etc/mysql/temp.cnf /tmp/

sudo systemctl start mysql