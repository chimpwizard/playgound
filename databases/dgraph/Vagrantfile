# -*- mode: ruby -*-
# vi: set ft=ruby :
#^syntax detection


VAGRANTFILE_API_VERSION = "2"
Vagrant.require_version ">= 1.8.1"
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

servers=[
  { :hostname => "master1", :ip => "10.17.0.20" },
  { :hostname => "console", :ip => "10.17.0.10" },
  { :hostname => "node1",   :ip => "10.17.0.30" },
  { :hostname => "node2",   :ip => "10.17.0.40" }
]

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = "bento/ubuntu-16.04"

      #node.vm.box = "ubuntu/xenial64"
      #node.vm.box = "centos/7"
      #node.vm.box = "debian/jessie64"
      #node.vm.box = "generic/rhel7"
      #node.vm.box = "mrlunar/windows-server-2016-containers"
      #node.vm.box = "https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-vagrant.box"

      node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", ip:machine[:ip]
      #node.vm.box_version = "201801.02.0"

      node.vm.provider :virtualbox do |vb|
        vb.memory=1024  # 4096
        vb.cpus = 1     # 4
      end

      if node.vm.hostname == "console"
        node.vm.synced_folder ".", "/home/app", owner: "vagrant", group: "vagrant"
        node.vm.provision "file", source: "./scripts", destination: "$HOME/scripts"
        node.vm.provision "shell", privileged:false, path:"./scripts/vagrant/provision.sh", args:["#{servers[0][:ip]}","#{ENV['PLATFORM']}"]
      end

      if node.vm.hostname != "console"
        node.vm.provision "file", source: "./scripts", destination: "$HOME/scripts"
        node.vm.provision "shell", privileged:false, path:"./scripts/vagrant/provision.sh", args:["#{servers[0][:ip]}","#{ENV['PLATFORM']}"]
      end
    end
  end

end
