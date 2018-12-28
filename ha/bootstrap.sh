#!/bin/bash

# 1. First which redis version is installed, I will prefer 4.0.11 in this article.
# 2. Then configure OS specific language settings.
# 3. Install build-essential and tcl packages. Redis is build manually then make command needs these libraries.
# 4. Download the redis file and extract it into a folder.
# 5. Then with make command, build redis binary. It you wish by make test command, tests should be run.
# 6. By providing the file locations and redis port to the ./utils/install_server.sh, necessary system services are created.
#    Both redis-server and redis-sentinel services are created.
# 7. So as to configure master and slaves, the redis services are stopped.


#1
VERSION=$1
FOLDER=redis-${VERSION}

#2
export LANGUAGE="en_US.UTF-8"
echo 'LANGUAGE="en_US.UTF-8"' | sudo tee -a /etc/default/locale
echo 'LC_ALL="en_US.UTF-8"' | sudo tee -a /etc/default/locale

#3
sudo apt-get update
sudo apt-get install -y build-essential tcl

#4
wget http://download.redis.io/releases/${FOLDER}.tar.gz
tar xvzf ${FOLDER}.tar.gz
cd ${FOLDER}

#5
make

# make test

sudo make install

#6
sudo REDIS_PORT=6379 \
REDIS_CONFIG_FILE=/etc/redis/6379.conf \
REDIS_LOG_FILE=/var/log/redis_6379.log \
REDIS_DATA_DIR=/var/lib/redis/6379 \
REDIS_EXECUTABLE=`command -v redis-server` ./utils/install_server.sh

sudo REDIS_PORT=26379 \
REDIS_CONFIG_FILE=/etc/redis/26379.conf \
REDIS_LOG_FILE=/var/log/redis_26379.log \
REDIS_DATA_DIR=/var/lib/redis/26379 \
REDIS_EXECUTABLE=`command -v redis-sentinel` ./utils/install_server.sh

#7
echo "stopping default servers ..."
sudo /etc/init.d/redis_26379 stop || die "Failed stopping redis-sentinel..."
sudo /etc/init.d/redis_6379 stop || die "Failed stopping redis-server..."

cd ..