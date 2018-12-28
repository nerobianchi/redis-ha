#!/bin/bash -e
ROLE=$1

VERSION=4.0.11

QUORUM=${QUORUM:-2}

MASTER_CONF=./master.conf
SLAVE_CONF=./slave.conf
SENTINEL_CONF=./sentinel.conf

sed -i "s/%redis-password%/${REDIS_PASS}/" $MASTER_CONF

sed -i "s/%master-ip%/${MASTER_HOST}/" $SLAVE_CONF
sed -i "s/%redis-password%/${REDIS_PASS}/" $SLAVE_CONF

sed -i "s/%master-ip%/${MASTER_HOST}/" $SENTINEL_CONF
sed -i "s/%redis-password%/${REDIS_PASS}/" $SENTINEL_CONF
sed -i "s/%quorum%/${QUORUM}/" $SENTINEL_CONF

if [[ $ROLE == "master" ]]; then
    REDIS_PASS=$REDIS_PASS VERSION=$VERSION ./install_master.sh
else
    REDIS_PASS=$REDIS_PASS VERSION=$VERSION ./install_slave.sh
fi

echo "sentinel conf is copying"
sudo cp ./sentinel.conf /etc/redis/26379.conf

echo "sentinel service is restarting"

set +e
while true; do
    timeout 3 redis-cli -a ${REDIS_PASS} -h ${MASTER_HOST} -p 6379 INFO
    if [[ "$?" == "0" ]]; then
        break
    fi
    echo "Connecting to master failed.  Waiting..."
    sleep 5
done
set -e

sudo service redis_26379 restart
echo "sentinel service is restarted"

echo "sentinel service status"
sudo systemctl status --no-pager --full redis_26379