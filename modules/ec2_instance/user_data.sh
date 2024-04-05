#!/bin/bash
sudo su
yum update -y
yum install -y httpd
echo "<h1> Welcome on the <font color='red'>GradixApp $(hostname -f)</font></h1>" > /var/www/html/index.html
systemctl start httpd
