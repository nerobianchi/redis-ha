# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

MASTER_NODE_COUNT=1
SLAVE_NODE_COUNT=2

MASTER_NODE_IP_START="10.0.0."

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 1
    end

    config.vm.box = "ubuntu/xenial64"
    config.vm.box_download_insecure = true

    (1..MASTER_NODE_COUNT).each do |i|
    config.vm.define "redis-master-#{i}" do |node|
        node.vm.hostname = "redis-master-#{i}"
        node.vm.network :private_network, ip: "#{MASTER_NODE_IP_START}#{ 10 + i }"
        node.vm.network "forwarded_port", guest:6379, host: "#{6378 + i}"
        node.vm.network "forwarded_port", guest:26379, host: "#{26378 + i}"

        node.vm.provision "shell", inline: "sed 's/127.0.0.1.*m/#{MASTER_NODE_IP_START}#{i} m/' -i /etc/hosts"
        node.vm.provision "shell", inline: "echo 'cd /vagrant' >> ~/.bashrc && exit", privileged: false
    end
  end
        
  (1..SLAVE_NODE_COUNT).each do |i|
    config.vm.define "redis-slave-#{i}" do |node|
        node.vm.hostname = "redis-slave-#{i}"
        node.vm.network :private_network, ip: "#{MASTER_NODE_IP_START}#{10 + MASTER_NODE_COUNT + i }"
        node.vm.network "forwarded_port", guest:6379, host: "#{6378 + MASTER_NODE_COUNT + i }"
        node.vm.network "forwarded_port", guest:26379, host: "#{26378 + MASTER_NODE_COUNT + i }"

        node.vm.provision "shell", inline: "sed 's/127.0.0.1.*m/#{MASTER_NODE_IP_START}#{i} m/' -i /etc/hosts"
        node.vm.provision "shell", inline: "echo 'cd /vagrant' >> ~/.bashrc && exit", privileged: false
    end
  end
end
