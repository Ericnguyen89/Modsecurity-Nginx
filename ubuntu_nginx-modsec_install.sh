#!/bin/bash

# Update package index and install build dependencies
sudo apt update
sudo apt-get install -y build-essential git libpcre3-dev libssl-dev

# Clone the modsecurity repository
git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity

# Clone the libnginx-mod-http-modsecurity repository
git clone --depth 1 https://github.com/SpiderLabs/libmodsecurity

# Build and install ModSecurity
cd ModSecurity
./build.sh
git submodule init
git submodule update
./configure
make
sudo make install

# Build libnginx-mod-http-modsecurity
cd ../libmodsecurity
./autogen.sh
./configure --enable-standalone-module --disable-mlogc
make

# Assuming nginx source is available in the following directory
# Change this path according to your nginx source location
#nginx_source_path="/path/to/nginx/source"
nginx_source_path=$(find / -type d -name "modules" -path "*/nginx/*" 2>/dev/null | head -n 1)
# Copy the compiled module to the nginx modules directory
sudo cp objs/ngx_http_modsecurity_module.so $nginx_source_path

# Compile nginx with the ModSecurity module
cd $nginx_source_path
./configure --add-dynamic-module=modules/ngx_http_modsecurity_module
make
sudo make install

# Restart nginx
sudo service nginx restart

