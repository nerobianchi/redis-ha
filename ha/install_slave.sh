#!/bin/bash -e

./bootstrap.sh ${VERSION}

echo "slave conf is copying"

sudo cp ./slave.conf /etc/redis/6379.conf
sudo sed -i "s/ shutdown$/ -a ${REDIS_PASS} shutdown/" /etc/init.d/redis_6379
sudo systemctl daemon-reload

echo "slave service is restarting"
sudo service redis_6379 restart
echo "slave service is restarted"

echo "slave service status:"
sudo systemctl status --no-pager --full redis_6379