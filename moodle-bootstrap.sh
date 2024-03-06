#!/bin/bash
# Installing Moodle
# Pre-reqs: AMP
# 1. Apache
# 2. Mysql
# 3. PHP

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Installing other linux dependencies
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
sudo apt update
sudo apt -y install php8.1
sudo apt -y install apache2
sudo apt -y install mysql-server
sudo apt -y install mysql-client
sudo apt -y install php-cli
sudo apt -y install php-mysql
sudo apt -y install php-mbstring
sudo apt -y install php-xml
sudo apt -y install php-curl
sudo apt -y install php-zip
sudo apt -y install php-gd
sudo apt -y install php-intl
sudo apt -y install php-soap
sudo apt -y install curl
sudo apt -y install vim


#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Setting Up mysql
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
PWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16 ; echo '')
echo $PWORD > /tmp/pword
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
# Setting PHP Vars
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
sudo sed -i '426s/.*/max_input_vars = 5000/' /etc/php/8.1/apache2/php.ini
sudo systemctl restart apache2

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Install Moodle
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
cd /var/www/html/
sudo rm index.html
sudo wget https://github.com/s1ddly/moodle/archive/refs/heads/main.zip
sudo unzip -q main.zip
sudo mv moodle-main/ moodle
sudo rm main.zip
sudo chown -R $USER:$USER moodle
sudo mkdir /var/www/moodledata
sudo chown www-data:www-data /var/www/moodledata
sudo chmod 777 /var/www/moodledata

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Configure Moodle
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
cd /var/www/html/moodle
#sed -i '2783s/.*/        $result->setStatus(true)/' /var/www/html/moodle/lib/upgradelib.php
php /var/www/html/moodle/admin/cli/install.php --chmod=2777 --lang=en --wwwroot=http://localhost:80 --dataroot=/var/www/moodledata --dbtype=mysqli --dbhost=localhost --dbname=main --dbuser=main --dbpass=$PWORD --prefix=mdl_ --dbport=3306 --fullname=learno --shortname=learno --adminuser=admin --adminpass=password --non-interactive
#php /var/www/html/moodle/admin/cli/install_database.php --lang=en --fullname=learno --shortname=learno --summary=learno --supportemail=test@gmail.com --adminuser=admin --adminpass=Password_1 --adminemail=admin@testmail.com --agree-license