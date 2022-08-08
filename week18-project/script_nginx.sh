#!/bin/bash
apt-get update -y
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx
echo "<html><body><h1>Welcome to my other custom NGINX webpage</h1></body></html>" > /var/www/html/index.html
