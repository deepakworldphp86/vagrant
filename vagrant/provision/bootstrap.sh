#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
           
# update

sudo apt-get update
sudo apt-get -y upgrade

# Install required command software
sudo apt-get -y install software-properties-common
sudo apt-get update
sudo apt-get -y install expect zip unzip


# Install curl software
if !  [ -x "$(command which curl)" ]; then

sudo apt-get -y install curl 
else
    
     echo "Curl already installed."

fi

# Install git 
if !  [ -x "$(command which git)" ]; then
sudo apt-get -y install curl git
else
    
     echo "Git already installed."

fi

# Install nginx software

if !  [ -x "$(command which nginx)" ]; then
    sudo apt-get -y install nginx
    sudo service nginx start
    sudo service nginx status
    sudo ufw allow OpenSSH
    sudo ufw allow 'Nginx HTTP'
    sudo ufw enable
    sudo ufw status
    sudo service nginx reload
else
    
     echo "Nginx already installed."

fi


# PHP install
if !  [ -x "$(command which php)" ]; then
    sudo apt-get  install -y php7.2-common php7.2-cli php7.2-fpm php7.2-opcache php7.2-gd php7.2-mysql php7.2-curl 
    php7.2-intl php7.2-xsl php7.2-mbstring php7.2-zip php7.2-bcmath php7.2-soap
    systemctl status php7.2-fpm
else
    
     echo "PHP already installed."

fi

# Maria DB install
if !  [ -x "$(command which mysql)" ]; then
  sudo apt-get install -y mariadb-server mariadb-client
  sudo systemctl stop mariadb.service
  sudo systemctl start mariadb.service
  sudo systemctl enable mariadb.service
  sudo systemctl status mariadb
else
   echo "Mysql already installed."
fi


# Composer 
if  [ -x "$(command which composer)" ]; then
     sudo curl -sS https://getcomposer.org/installer | sudo php -dmemory_limit=-1 -- --install-dir=/usr/local/bin --filename=composer
     composer -V
else
    
     echo "Composer already installed."
fi


#***********************************Mysql secure instalation************************#
  
MYSQL=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $11}')

 MYSQL_PASS=admin123

expect -f - <<-EOF
  set timeout 10
  spawn mysql_secure_installation
  expect "Enter current password for root (enter for none):"
  send -- "\r"
  expect "Set root password?"
  send -- "y\r"
  expect "New password:"
  send -- "${MYSQL_PASS}\r"
  expect "Re-enter new password:"
  send -- "${MYSQL_PASS}\r"
  expect "Remove anonymous users?"
  send -- "y\r"
  expect "Disallow root login remotely?"
  send -- "y\r"
  expect "Remove test database and access to it?"
  send -- "y\r"
  expect "Reload privilege tables now?"
  send -- "y\r"
  expect eof
EOF




#****************Create Database && DB import*********************#

#sudo mysql -u root -e "CREATE DATABASE IF NOT EXISTS citymedr_citymedrx"; 
#sudo mysql -u root -p 
#sudo mysql -u root -e "use  citymedr_citymedrx"; 
#sudo mysql -u root -e "source  citymedrx_15_nov_19.sql"; 
#mysqldump -u root -padmin123 citymedr_citymedrx>$citymedrx_15_nov_19".sql"




#*****************End database create and DB import **************#


#****************Magento install by composer*********************#
#sudo rm -rf "/var/www/html/citymedrx.vg.com"
#sudo php -r "echo ini_get('memory_limit').PHP_EOL;"
#
#
#MAGENTO_USER=cb5827454c5bc0aefa23f4e950600c0a
#MAGENTO_PASS=9b5d26b053d8959a9af0038fe4be8390
#
#MAGENTO_INSTALL=$(expect -c "
#set timeout 100
#spawn sudo composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition /var/www/html/citymedrx.vg.com
#expect \"Username:\"
#send \"${MAGENTO_USER}\r\"
#expect \"Password:\"
#send \"${MAGENTO_PASS}\r\"
#expect \"Do you want to store credentials for repo.magento.com\"
#send \"y\r\"
#expect eof
#")
#
##if ! [ -d "/var/www/html/citymedrx.vg.com" ]; then
# echo "$MAGENTO_INSTALL"
##fi 

#****************End*********************#

# set up nginx server
#set up nginx server

#****************Magento install by composer*********************#
if [ -f "/var/www/html/citymedrx.vg.com/nginx.conf.sample" ]; then
cat << EOF > /etc/nginx/sites-available/nginx.conf
    server {

         listen 80;
         server_name  citymedrx.vg.com;
         access_log /var/log/nginx/access.log;
         error_log /var/log/nginx/error.log;

         set $MAGE_ROOT /var/www/html/citymedrx.vg.com;
         include /var/www/html/citymedrx.vg.com/nginx.conf.sample;
     }
EOF
sudo chmod 644 /etc/nginx/sites-available/nginx.conf
sudo ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/nginx.conf
sudo service nginx restart
fi

#****************End*********************#

#
#
## clean /var/www
#sudo rm -Rf /var/www/html
#
## symlink /var/www => /vagrant
#sudo ln -s /vagrant /var/www/html
