#!/bin/bash
echo "*********************************************************************"
echo "PARAMS: "
echo "   IP: $1"
echo "*********************************************************************"


echo "*********************************************************************"
echo "Update system"
echo "*********************************************************************"
sudo apt-get update
 
echo "*********************************************************************"
echo "Installing dependencies"
echo "*********************************************************************"

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common




echo "*********************************************************************"
echo "Installing docker"
echo "*********************************************************************"

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get install -y docker.io



echo "*********************************************************************"
echo "Give docekr access to vagrant"
echo "*********************************************************************"
sudo usermod -aG docker vagrant

sudo chmod 777 /var/run/docker.sock


echo "*********************************************************************"
echo "Install kubeadmin"
echo "*********************************************************************"
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > ./tmp
sudo cp ./tmp /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

#sudo apt-get install -qy kubelet=1.10.0 kubeadm=1.10.0 kubectl=1.10.0 kubernetes-cni=0.6.0
#sudo apt install -y kubeadm  kubelet kubectl kubernetes-cni
sudo apt-get install -y kubelet=1.9.0-00 kubeadm=1.9.0-00 kubectl=1.9.0-00

#sudo apt install -y kubelet=1.8.4-00 kubernetes-cni=0.5.1-00 kubectl=1.8.4-00 kubeadm=1.8.4-00

echo "*********************************************************************"
echo "Set host name resolution"
echo "*********************************************************************"

#
# This is important to be able to connect to the pods otherwise you will see
# resource not found
#
echo 'set host name resolution'
cp /etc/hosts /tmp/hosts
sudo echo  '''
172.10.10.20 master1
172.10.10.30 node1
172.10.10.40 node2
'''>> /tmp/hosts
sudo cp /tmp/hosts /etc/hosts
cat /etc/hosts

# echo 'set nameserver'
# cp /etc/hosts /tmp/resolv.conf
# echo "nameserver 8.8.8.8">/tmp/resolv.conf
# sudo cp /tmp/resolv.conf /etc/resolv.conf
# cat /etc/resolv.conf

echo "*********************************************************************"
echo "Turn Off swap"
echo "*********************************************************************"
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a
# keep swap off after reboot
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

#configuring Kubernetes to use the same CGroup driver as Docker
# sed -i '/ExecStart=/a Environment="KUBELET_EXTRA_ARGS=--cgroup-driver=cgroupfs"' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo sed -i '0,/ExecStart=/s//Environment="KUBELET_EXTRA_ARGS=--cgroup-driver=cgroupfs"\n&/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# echo "*********************************************************************"
# echo "Check connectivity to kubernetes repos"
# echo "*********************************************************************"
# sudo kubeadm config images pull


if [[ "$HOSTNAME" == master* ]]
then

 #When the network is private and type=dhcp
 #IPADDR=`ifconfig enp0s8 | grep Mask | awk '{print $2}'| cut -f2 -d:` 
 IPADDR=$(hostname -i)
 NODENAME=$(hostname -s)


 echo "*********************************************************************"
 echo "Configure Kubernetes ( node: ${NODENAME} ) and Init Cluster @ $1 IPADDR=${IPADDR}"
 echo "*********************************************************************"
# http://cidr.xyz 
# node range: 172.17.0.0/24
# svc  range: 172.17.1.0/24
# pod  range: 172.16.0.0/16

# node range: 10.17.0.0/24
# svc  range: 10.17.1.0/24
# pod  range: 10.244.0.0/16

# --service-cidr default  "10.96.0.0/12"
 #
 # NOTE: After using the default 10* range address the dns CrashLoopBackOff got resolved
 #
 #sudo  kubeadm init --apiserver-advertise-address=$1 --pod-network-cidr=10.244.0.0/16 --apiserver-cert-extra-sans=$1 | tee | awk '/--token/ {print $0}' > /vagrant/k8s-token
 sudo  kubeadm init --apiserver-advertise-address=$1 --pod-network-cidr=10.244.0.0/16 --apiserver-cert-extra-sans=$1,localhost,localhost.localdomain,127.0.0.1 | tee | awk '/--token/ {print $0}' > /vagrant/k8s-token
 #sudo  kubeadm init   | tee | awk '/--token/ {print $0}' > /vagrant/k8s-token


 ##NOTE use this flag when connecting remotrly --apiserver-cert-extra-sans $fqdn'

 echo "*********************************************************************"
 echo "Bind on all interfaces and accept connections from any hosts"
 echo "*********************************************************************"
 #failing
 #sudo sed -i 's/"KUBECTL_PROXY_ARGS=.*"/"KUBECTL_PROXY_ARGS=--port 8001 --accept-hosts='.*' --address=0.0.0.0"/' /etc/systemd/system/kubectl-proxy.service.d/10-kubectl-proxy.conf


 echo "*********************************************************************"
 echo "Copy kube.config to to vagrant home"
 echo "*********************************************************************"

 mkdir -p $HOME/.kube
 sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
 sudo chown vagrant:vagrant $HOME/.kube/config
 sudo cp /etc/kubernetes/admin.conf /vagrant/kube.config
 sudo chmod 777 /vagrant/kube.config

 echo "*********************************************************************"
 echo "Allow run PODs on master"
 echo "*********************************************************************"
 sudo kubectl taint nodes --all node-role.kubernetes.io/master-
 echo "*** CHECK TAINTS"
 sudo kubectl get no -o yaml | grep taint -A 5

 echo "*********************************************************************"
 echo "Install POD network"
 echo "*********************************************************************"
 sudo sysctl net.bridge.bridge-nf-call-iptables=1

 sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
 #sudo kubectl apply -f https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')
 sudo curl https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml|sed 's/"--kube-subnet-mgr"/"--kube-subnet-mgr", "--iface=eth1"/'|sudo kubectl apply -f -



 sudo kubectl get pods --all-namespaces

# AF: This recommended patch didnt work
#  echo "*********************************************************************"
#  echo "PATCH: for coredns CrashLoopBackOff issue"
#  echo "*********************************************************************"
#  sudo kubectl -n kube-system get deployment coredns -o yaml | \
#   sed 's/allowPrivilegeEscalation: false/allowPrivilegeEscalation: true/g' | \
#   kubectl apply -f -



 echo "*********************************************************************"
 echo "Show Nodes"
 echo "*********************************************************************"
 kubectl --kubeconfig .kube/config get nodes

fi

if [[ "$HOSTNAME" == node* ]]
then
 sudo chmod 777 /var/run/docker.sock

 echo "*********************************************************************"
 echo "Join cluster"
 echo "*********************************************************************"
 #kubeadm join --token <token> <master-ip>:<master-port> --discovery-token-ca-cert-hash sha256:<hash>
 sudo sed -i '/swap/d' /etc/fstab
 sudo `cat /vagrant/k8s-token`

 #sudo docker swarm join --token `cat /vagrant/swarm-token` $1:2377
fi

if [[ "$HOSTNAME" == console* ]]
then


 #Install docker compose and start weave scope
 echo "*********************************************************************"
 echo "Installing docker compose"
 echo "*********************************************************************"
 #sudo apt install -y docker-compose
 export DOCKER_COMPOSE_VERSION=1.13.0
 sudo curl --insecure -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > ./dc
 sudo cp ./dc //usr/local/bin/docker-compose 
 sudo chmod +x /usr/local/bin/docker-compose

 #Install developer tools
 echo "*********************************************************************"
 echo "Installing developer tools"
 echo "*********************************************************************"
 sudo apt-get install -y git
 curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
 sudo apt-get install -y nodejs
 sudo apt-get install -y build-essential
 sudo apt-get install -y npm
 sudo npm install npm --global
 sudo apt-get install dos2unix

 echo "*********************************************************************"
 echo "Use kube.config for configuration"
 echo "*********************************************************************"
 #no need to copy since there is already a mapping to /home/app
 #sudo mkdir -p $HOME/.kube
 #sudo cp /vagrant/kube.config $HOME/.kube/config
 #sudo chown vagrant:vagrant $HOME/.kube/config
 sudo echo "export KUBECONFIG=/home/app/kube.config" >> /home/vagrant/.bashrc


echo "*********************************************************************"
echo "Install snap and helm"
echo "*********************************************************************"
sudo apt install -y snapd
sudo snap install helm --classic
#curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | sudo -

fi

echo "*********************************************************************"
echo "DONE $HOSTNAME"
echo "*********************************************************************"


