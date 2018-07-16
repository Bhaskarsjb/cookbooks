#!/bin/bash
yum update -y
yum install httpd -y
cd /var/www/html
echo "Test script resource using chef" > index.html
echo "This is healthy" > healthy.html
service httpd start
chkconfig httpd on
