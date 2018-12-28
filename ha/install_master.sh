#!/bin/bash -e

./bootstrap.sh ${VERSION}

echo "master conf is copying"

sudo cp ./master.conf /etc/redis/6379.conf
sudo sed -i "s/ shutdown$/ -a ${REDIS_PASS} shutdown/" /etc/init.d/redis_6379
sudo systemctl daemon-reload

echo "master service is restarting"
sudo service redis_6379 restart
echo "master service is restarted"

echo "master service status:"
sudo systemctl status --no-pager --full redis_6379