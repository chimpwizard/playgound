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
echo "Installing docker"
echo "*********************************************************************"

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

#sudo apt-get install -y docker-ce
sudo apt-get install -y docker.io

echo "*********************************************************************"
echo "Give docekr access to vagrant"
echo "*********************************************************************"
sudo usermod -aG docker vagrant

sudo chmod 777 /var/run/docker.sock

# sudo mkdir -p /etc/docker
# sudo echo "{ \"insecure-registries\":[\"$1:5000\"] }" | sudo tee /etc/docker/daemon.json
# sudo service docker restart && echo "docker service restarted"

echo "*********************************************************************"
echo "Install kubeadmin"
echo "*********************************************************************"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > ./tmp
#sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
sudo cp ./tmp /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y golang-go kubelet kubeadm kubectl
#sudo go get github.com/kubernetes-incubator/cri-tools/cmd/crictl



if [[ "$HOSTNAME" == master* ]]
then

 echo "*********************************************************************"
 echo "Configure Docker and Init Swarm @ $1 "
 echo "*********************************************************************"
 
 sudo  kubeadm init --apiserver-advertise-address=$1 --pod-network-cidr=10.244.0.0/16| tee | awk '/--token/ {print $0}' > /vagrant/k8ts-token

 sudo chmod 777 /var/run/docker.sock

 echo "*********************************************************************"
 echo "Give docekr access to vagrant"
 echo "*********************************************************************"

 mkdir -p $HOME/.kube
 sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
 sudo chown vagrant:vagrant $HOME/.kube/config
 sudo cp -i /etc/kubernetes/admin.conf /vagrant/kube.config
 sudo chmod 777 /vagrant/kube.config


 echo "*********************************************************************"
 echo "Install POD network"
 echo "*********************************************************************"
 sudo sysctl net.bridge.bridge-nf-call-iptables=1
 sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
 sudo kubectl get pods --all-namespaces

 echo "*********************************************************************"
 echo "Allow run PODs on master"
 echo "*********************************************************************"
 sudo kubectl taint nodes --all node-role.kubernetes.io/master-

 #Install docker compose and start weave scope
 echo "*********************************************************************"
 echo "Installing docker compose"
 echo "*********************************************************************"
 #sudo apt install -y docker-compose
 export DOCKER_COMPOSE_VERSION=1.13.0
 sudo curl --insecure -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > ./dc
 sudo cp ./dc //usr/local/bin/docker-compose 
 sudo chmod +x /usr/local/bin/docker-compose

 echo "*********************************************************************"
 echo "Show Nodes"
 echo "*********************************************************************"
 kubectl --kubeconfig .kube/config get nodes

fi

if [[ "$HOSTNAME" == node* ]]
then
 sudo chmod 777 /var/run/docker.sock

 echo "*********************************************************************"
 echo "Join Swarm"
 echo "*********************************************************************"
 #kubeadm join --token <token> <master-ip>:<master-port> --discovery-token-ca-cert-hash sha256:<hash>
 sudo `cat /vagrant/k8ts-token`

 #sudo docker swarm join --token `cat /vagrant/swarm-token` $1:2377
fi

echo "*********************************************************************"
echo "DONE $HOSTNAME"
echo "*********************************************************************"

