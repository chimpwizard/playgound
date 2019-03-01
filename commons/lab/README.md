# Vagrant lab

```yaml
by: иÐгü
email: ndru@chimpwizard.com
date: 10.1.2018
version: draft
```

****

The goal of this POC is to get an environment that can be use as a building block for other POCs. The core technology is based on containers using docker swarm or kubernetes.

I provide provisioning sample scripts for:

- Ubuntu
- Centos
- RHEL
- Windows

## Architecture

The proposed architecture is as follows.

## The implementation

The lab is provisioned usig [vagrant](https://www.vagrantup.com/intro/index.html) and it gives the option to provision a docker swarm or a kubernetes cluster on different flavors of linux.

The vagrant file:

```vagrant
# -*- mode: ruby -*-
# vi: set ft=ruby :
#^syntax detection


VAGRANTFILE_API_VERSION = "2"
Vagrant.require_version ">= 1.8.1"
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

#
# Order matters b/c we need master kube.config on console
#
servers=[
  { :hostname => "master1", :ip => "172.10.10.20" },
  { :hostname => "console", :ip => "172.10.10.10" },
  { :hostname => "node1",   :ip => "172.10.10.30" },
  { :hostname => "node2",   :ip => "172.10.10.40" }
]

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = "bento/ubuntu-16.04"

      node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", ip:machine[:ip]

      node.vm.provider :virtualbox do |vb|
        vb.memory=2048  # 4096
        vb.cpus = 1     # 4
      end

      if node.vm.hostname == "console"
        node.vm.synced_folder ".", "/home/app", owner: "vagrant", group: "vagrant"
        node.vm.provision "file", source: "./scripts", destination: "$HOME/scripts"
        node.vm.provision "file", source: "./samples", destination: "$HOME/samples"
        node.vm.provision "shell", privileged:false, path:"./scripts/vagrant/provision.sh", args:["#{servers[0][:ip]}","#{ENV['PLATFORM']}"]
      end

      if node.vm.hostname != "console"
        node.vm.provision "file", source: "./scripts", destination: "$HOME/scripts"
        node.vm.provision "shell", privileged:false, path:"./scripts/vagrant/provision.sh", args:["#{servers[0][:ip]}","#{ENV['PLATFORM']}"]
      end
    end
  end

end
```

## Prerequisites to run the code

- install [npm](https://docs.npmjs.com/getting-started/what-is-npm)
- install [vagrant](https://www.vagrantup.com/intro/index.html)

### to start the cluster

```shell
npm run up:swarm      # To create the docker swarm cluster
#npm run up:k8s       # To create the kubernetes cluster
```

### to clean up your machine

```shell
npm run destroy
```

## Some references while doing this

- https://www.vagrantup.com/docs/provisioning/shell.html
- https://app.vagrantup.com/boxes/search
- https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
- https://github.com/helm/charts/tree/master/stable/mysql/templates
- https://stackoverflow.com/questions/48556971/unable-to-install-kubernetes-charts-on-specified-namespace
- https://github.com/kubernetes/dashboard/wiki/Installation
- https://letsencrypt.org/getting-started/
- https://github.crookster.org/Kubernetes-Ubuntu-18.04-Bare-Metal-Single-Host/
- https://mherman.org/blog/setting-up-a-kubernetes-cluster-on-ubuntu/
- https://github.com/kubernetes/kubeadm/issues/980
- https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#master-isolation
- http://cidr.xyz
- https://www.ipaddressguide.com/cidr
- https://github.com/oracle/vagrant-boxes/blob/master/Kubernetes/Vagrantfile
- https://github.com/rootsongjc/kubernetes-vagrant-centos-cluster/blob/master/Vagrantfile


## Additional improvements

- Test provisioning scripts for other OS != ubuntu.






<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-43465642-1"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-43465642-1');
</script>