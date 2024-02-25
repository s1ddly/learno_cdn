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
sudo apt -y install php8.1-mysql
sudo apt -y install php8.1-xml
sudo apt -y install curl
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
/usr/bin/php /var/www/html/moodle/admin/cli/install.php

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
$CFG->dbpass    = '$PWORD';
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