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
sudo apt -y install vim

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
# Install Moodle
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
sudo mkdir /data/
cd /data/
sudo mkdir moodle
sudo chown $USER:$USER moodle
cd /var/www/html/
rm index.html
sudo get https://download.moodle.org/download.php/direct/stable403/moodle-latest-403.zip
sudo unzip -q moodle-latest-403.zip
sudo rm moodle-latest-403.zip
sudo chown $USER:$USER moodle
sudo mkdir /var/www/moodledata
sudo chown www-data:www-data /var/www/moodledata
#/usr/bin/php /var/www/html/moodle/admin/cli/install.php

#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
# Configure Moodle
#-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
cat << EOF > /var/www/html/moodle/config.php
<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mysqli';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'localhost';
$CFG->dbname    = 'main';
$CFG->dbuser    = 'main';
$CFG->dbpass    = 'yMtEtYDnL8VkDhu8';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => 3306,
  'dbsocket' => '',
  'dbcollation' => 'utf8mb4_0900_ai_ci',
);

$CFG->wwwroot   = 'http://localhost:80';
$CFG->dataroot  = '/data/moodle';
$CFG->admin     = 'admin';

$CFG->directorypermissions = 02777;

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
EOF

--fullname=STRING     The fullname of the site
--shortname=STRING    The shortname of the site
--summary=STRING      The summary to be displayed on the front page
--adminuser=USERNAME  Username for the moodle admin account. Default is admin
--adminpass=PASSWORD  Password for the moodle admin account,
                      required in non-interactive mode.
--adminemail=STRING   Email address for the moodle admin account.
--sitepreset=STRING   Admin site preset to be applied during the installation process.
--supportemail=STRING Email address for support and help.
--upgradekey=STRING   The upgrade key to be set in the config.php, leave empty to not set it.
--non-interactive     No interactive questions, installation fails if any
                      problem encountered.
--agree-license       Indicates agreement with software license,
                      required in non-interactive mode.
--allow-unstable      Install even if the version is not marked as stable yet,
                      required in non-interactive mode.
--skip-database       Stop the installation before installing the database.
-h, --help            Print out this help



php /var/www/html/moodle/admin/cli/install.php --chmod=2777 --lang=en --wwwroot=http://localhost:80 --dataroot=/data/moodle --dbtype=mysqli --dbhost=localhost --dbname=main --dbuser=main --dbpass=yMtEtYDnL8VkDhu8 --prefix=mdl_ --dbport=3306 --fullname=learno --shortname=learno --adminuser=admin --adminpass=password --non-interactive --agree-license