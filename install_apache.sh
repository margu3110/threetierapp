#!/bin/bash -xe
HOMEDIR=/home/ec2-user

yum update -y
yum update -y aws-cfn-bootstrap

amazon-linux-extras install lamp-mariadb10.2-php7.2

echo Installing packages...
echo Please ignore messages regarding SELinux...
yum install -y \
httpd \
mariadb-server \
php \
php-gd \
php-mbstring \
php-mysqlnd \
php-xml \
php-xmlrpc

echo Starting database service...
sudo systemctl start mariadb
sudo systemctl enable mariadb

echo Configuring Apache...
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www && find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo Starting Apache...
sudo systemctl start httpd
sudo systemctl enable httpd
sudo bash -c 'echo Congratulations! The webserver is online > /var/www/html/index.html'
