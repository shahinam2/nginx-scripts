#!/bin/bash

# Install the C compiler and supporting libraries first:
yum update -y
yum install wget -y
yum groupinstall "Development Tools" -y
yum install pcre pcre-devel zlib zlib-devel openssl openssl-devel make -y

# Make sure the download link is up to date.
# get the latest link from here:
# https://nginx.org/en/download.html
wget https://nginx.org/download/nginx-1.21.5.tar.gz

# extract, cd, configure:
# the extract part should be updated acording to nginx version.
tar -zxvf nginx-1.21.5.tar.gz
cd nginx-1.21.5
./configure --sbin-path=/usr/bin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-pcre --pid-path=/var/run/nginx.pid --with-http_ssl_module

# Compile and install Nginx
make
make install

# add the nginx systemd file:
echo "
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/bin/nginx -t
ExecStart=/usr/bin/nginx
ExecReload=/usr/bin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
" >> /lib/systemd/system/nginx.service

# reload the systemctl
systemctl daemon-reload

# Start and enable the service(auto-start on boot):
systemctl --now enable nginx

# To verify the installation:
nginx -v
