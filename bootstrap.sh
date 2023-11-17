#!/bin/bash
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Bootstrap script for the LearnAi website
# This script is available at https://sidshardanand.com/learno_cdn/bootstrap.sh
# Author: Sid Shardanand
# bootstrap commands:
# wget https://sidshardanand.com/learno_cdn/bootstrap.sh
# chmod 777 bootstrap.sh
# bash bootstrap.sh
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Installing/enabling ssh
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
sudo apt update
sudo apt -y install openssh-server
sudo systemctl enable ssh
sudo ufw allow ssh

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Installing other linux dependencies
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
sudo apt -y install php8.1
sudo apt -y install apache2
sudo apt -y install mysql-server
sudo apt -y install php-cli
sudo apt -y install php-xml
sudo apt -y install php-common
sudo apt -y install php-curl
sudo apt -y install php8.1-cli
sudo apt -y install php8.1-common
sudo apt -y install php8.1-curl
sudo apt -y install php8.1-mysql
sudo apt -y install php8.1-opcache
sudo apt -y install php8.1-readline
sudo apt -y install php8.1-xml
sudo apt -y install php8.1-zip
sudo apt -y install curl
sudo apt -y install vim

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Installing Composer
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
sudo sed "s/upload_max_filesize = 2M/upload_max_filesize = 50M/g" -i /etc/php/8.1/cli/php.ini
sudo service apache2 restart

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

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Setting Up project
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
sudo mkdir /opt/learnai/
sudo chmod 777 -R /opt/learnai/
cd /opt/learnai/
curl -k https://sidshardanand.com/learno_cdn/latest.zip > /opt/learnai/learnai.zip
unzip learnai.zip
chmod 777 -R Learnai-main
cd Learnai-main

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Initialising website
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
cat <<EOF > .env
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=main
DB_USERNAME='main'
DB_PASSWORD='$PWORD'

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1

VITE_APP_NAME="${APP_NAME}"
VITE_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="${PUSHER_HOST}"
VITE_PUSHER_PORT="${PUSHER_PORT}"
VITE_PUSHER_SCHEME="${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"
EOF

composer install 
php artisan key:generate
php artisan migrate
php artisan db:seed --class=UserSeeder

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Starting Server
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

nohup php artisan serve --port=8080 >> /tmp/serverlog.txt  2>&1 &

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# To shutdown the website, run the below
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

#sudo kill -9 $(sudo lsof -t -i:8080)