#!/bin/bash
echo "*********************************************************************"
echo "PARAMS: "
echo "   IP: $1"
echo "*********************************************************************"

echo "*********************************************************************"
echo "Update system"
echo "*********************************************************************"
sudo apt-get update 
#&& apt-get upgrade

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

sudo apt-get install -y docker.io


echo "*********************************************************************"
echo "Give docekr access to vagrant"
echo "*********************************************************************"
sudo usermod -aG docker vagrant


sudo chmod 777 /var/run/docker.sock

sudo mkdir -p /etc/docker
sudo echo "{ \"insecure-registries\":[\"$1:5000\"],\"experimental\":true }" | sudo tee /etc/docker/daemon.json
sudo service docker restart && echo "docker service restarted"


if [[ "$HOSTNAME" == master* ]]
then

 echo "*********************************************************************"
 echo "Configure Docker and Init Swarm"
 echo "*********************************************************************"
 
 sudo docker swarm init --advertise-addr $1 | tee | awk '/--token/ {print $2}' > /vagrant/swarm-token


 sudo cp /lib/systemd/system/docker.service /lib/systemd/system/docker.service.bavkup
 sudo sed -i "s/ExecStart=\/usr\/bin\/dockerd -H fd:\/\//ExecStart=\/usr\/bin\/dockerd -H fd:\/\/ -H tcp:\/\/0.0.0.0:4243/" /lib/systemd/system/docker.service 
 sudo cat /lib/systemd/system/docker.service
 sudo systemctl daemon-reload
 
 #Add Label
 #echo "DOCKER_OPTS=--label=node.type=manager" >> /etc/default/docker
 cp /etc/default/docker .
 echo "DOCKER_OPTS=--label=node.type=manager" >> ./docker
 sudo cp ./docker /etc/default/docker
 
 sudo service docker restart && echo "docker service restarted"
 
 sudo chmod 777 /var/run/docker.sock

fi

if [[ "$HOSTNAME" == node* ]]
then
 #Add Label
 #echo "DOCKER_OPTS=--label=node.type=worker" >> /etc/default/docker
 cp /etc/default/docker .
 echo "DOCKER_OPTS=--label=node.type=worker" >> ./docker
 sudo cp ./docker /etc/default/docker
 sudo service docker restart && echo "docker service restarted"
 
 sudo chmod 777 /var/run/docker.sock

 echo "*********************************************************************"
 echo "Join Swarm"
 echo "*********************************************************************"
 echo sudo docker swarm join --token `cat /vagrant/swarm-token` $1:2377
 sudo docker swarm join --token `cat /vagrant/swarm-token` $1:2377
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

 sudo echo "export DOCKER_HOST=tcp://$1:4243" >> /home/vagrant/.bashrc

fi

echo "*********************************************************************"
echo "DONE $HOSTNAME"
echo "*********************************************************************"

