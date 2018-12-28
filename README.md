# Redis HA Bootstrap

The scripts in order to create a 3 node, 1 master and 2 slaves redis cluster and redis sentinel in HA, based on article https://medium.com/@nerobianchi/installing-a-high-available-redis-cluster-5001ade17c43

These scripts are production proven. 

**However using the scripts are under the responsibility of the users.**

## Setting up vagrant

```bash
vagrant up
vagrant ssh redis-master-1
vagrant ssh redis-slave-1
vagrant ssh redis-slave-2
```

## Commands running in vagrant
master
-------------
```bash
sudo su -
cd
rm -Rf /tmp/redis-installation
mkdir /tmp/redis-installation
cd /tmp/redis-installation
cp -R /vagrant/ha/* /tmp/redis-installation
REDIS_PASS=this_is_a_very_secret_password \
MASTER_HOST=10.0.0.11 \
./install.sh master
cd /home
rm -Rf /tmp/redis-installation
```

slave
-------------
```bash
sudo su -
cd
rm -Rf /tmp/redis-installation
mkdir /tmp/redis-installation
cd /tmp/redis-installation
cp -R /vagrant/ha/* /tmp/redis-installation
REDIS_PASS=this_is_a_very_secret_password \
MASTER_HOST=10.0.0.11 \
./install.sh slave
cd /home
rm -Rf /tmp/redis-installation
```

test cases
-------------
  - when_master_ping_then_response_should_be_OK
  - when_slave1_ping_then_response_should_be_OK
  - when_slave2_ping_then_response_should_be_OK
  - when_setting_a_key_to_master_then_response_should_be_OK
  - when_setting_a_key_to_master_then_master_should_get_value_of_key #"hello"
  - when_setting_a_key_to_slave1_then_master_should_get_value_of_key #"hello"
  - when_setting_a_key_to_slave2_then_master_should_get_value_of_key #"hello"
  - when_setting_a_key_to_slave1_then_error_should_be_thrown # (error) READONLY You can't write against a read only slave.
  - when_setting_a_key_to_slave2_then_error_should_be_thrown # (error) READONLY You can't write against a read only slave.
  - given_1_master_2_slaves_when_master_node_halted_then_one_of_slaves_should_be_master
  - given_1_master_2_slaves_when_redis_failover_is_called_then_one_of_slaves_should_be_master

```bash
#FOR vagrant
MASTER_01=10.0.0.11
SLAVE_01=10.0.0.12
SLAVE_02=10.0.0.13
PASSWORD=this_is_a_very_secret_password

redis-cli -p 6379 -h $MASTER_01 -a $PASSWORD ping
redis-cli -p 6379 -h $SLAVE_01 -a $PASSWORD ping
redis-cli -p 6379 -h $SLAVE_02 -a $PASSWORD ping

redis-cli -p 6379 -h $MASTER_01 -a $PASSWORD SET mykey "hello"
redis-cli -p 6379 -h $SLAVE_01 -a $PASSWORD SET mykey "hello2"
redis-cli -p 6379 -h $SLAVE_02 -a $PASSWORD SET mykey "hello3"

redis-cli -p 6379 -h $MASTER_01 -a $PASSWORD GET mykey
redis-cli -p 6379 -h $SLAVE_01 -a $PASSWORD GET mykey
redis-cli -p 6379 -h $SLAVE_02 -a $PASSWORD GET mykey

redis-cli -p 6379 -h $SLAVE_02 -a $PASSWORD SET mykey "hello2"
redis-cli -p 6379 -h $SLAVE_02 -a $PASSWORD GET mykey

redis-cli -p 6379 -h $MASTER_01 -a $PASSWORD DEL mykey

redis-cli -p 6379 -h $MASTER_01 -a $PASSWORD debug segfault
redis-cli -p 6379 -h $MASTER_01 -a $PASSWORD shutdown


redis-cli -p 26379 -h $MASTER_01 ping
redis-cli -p 26379 -h $MASTER_01 sentinel get-master-addr-by-name redis-cluster
redis-cli -p 26379 -h $MASTER_01 sentinel masters
redis-cli -p 26379 -h $MASTER_01 sentinel slaves redis-cluster
redis-cli -p 26379 -h $MASTER_01 sentinel failover redis-cluster

redis-cli -p 26379 -h $SLAVE_01 sentinel get-master-addr-by-name redis-cluster
redis-cli -p 26379 -h $SLAVE_01 sentinel masters
redis-cli -p 26379 -h $SLAVE_01 sentinel failover redis-cluster

watch -d "redis-cli -p 26379 -h $MASTER_01 sentinel masters"
watch -d "redis-cli -p 26379 -h $MASTER_01 sentinel slaves redis-cluster"
watch -d "redis-cli -p 26379 -h $SLAVE_01 sentinel masters"
watch -d "redis-cli -p 26379 -h $SLAVE_01 sentinel slaves redis-cluster"
watch -d "redis-cli -p 26379 -h $SLAVE_02 sentinel masters"
watch -d "redis-cli -p 26379 -h $SLAVE_02 sentinel slaves redis-cluster"
```

clean
-------------
```bash
sudo systemctl stop redis_26379
sudo systemctl disable redis_26379
rm /etc/systemd/system/redis_26379

sudo /etc/init.d/redis_26379 stop
sudo rm -Rf /var/lib/redis/26379
sudo rm /var/log/redis_26379.log
sudo rm -Rf /etc/init.d/redis_26379
sudo rm /var/run/redis_26379.pid


sudo systemctl stop redis_6379
sudo systemctl disable redis_6379
rm /etc/systemd/system/redis_6379

sudo /etc/init.d/redis_6379 stop
sudo rm -Rf /var/lib/redis/6379
sudo rm /var/log/redis_6379.log
sudo rm -Rf /etc/init.d/redis_6379
sudo rm /var/run/redis_6379.pid

sudo rm -Rf /etc/redis

sudo find /usr/local/bin -name 'redis*' -delete

sudo systemctl daemon-reload
sudo systemctl reset-failed
```

data dir
-------------
```bash
redis-cli config get dir #get data directory
```