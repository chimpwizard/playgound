#!/bin/bash
echo "*********************************************************************"
echo "Update system"
echo "*********************************************************************"
yum update -y

echo "*********************************************************************"
echo "Installing docker"
echo "*********************************************************************"

yum -y install yum-utils device-mapper-persistent-data lvm2
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --disable docker-testing
yum makecache fast
yum -y install docker-ce

echo "*********************************************************************"
echo "Give docekr access to cw"
echo "*********************************************************************"
usermod -aG docker cw

chmod 777 /var/run/docker.sock

#mkdir -p /etc/docker
echo "{ \"insecure-registries\":[\"$1:5000\"] }" | tee /etc/docker/daemon.json

systemctl enable docker.service
systemctl enable docker
systemctl start docker && echo "docker service started"

echo "*********************************************************************"
echo "Open Ports"
echo "*********************************************************************"
# iptables -A INPUT -p tcp --dport 2375 -j ACCEPT
# iptables -A INPUT -p tcp --dport 2376 -j ACCEPT
# iptables -A INPUT -p tcp --dport 2377 -j ACCEPT
# iptables -A INPUT -p tcp --dport 4243 -j ACCEPT
# iptables -A INPUT -p tcp --dport 7946 -j ACCEPT
# iptables -A INPUT -p udp --dport 7946 -j ACCEPT
# iptables -A INPUT -p udp --dport 4789 -j ACCEPT

#
# TODO: use vm_role property instead servername
#


#if [[ "$HOSTNAME" == *manager* || "$HOSTNAME" == *master* ]]
if [[ "$HOSTNAME" == master* ]]

then

echo "*********************************************************************"
echo "Configure Docker and Init Swarm"
echo "*********************************************************************"

MYIP=$(hostname -i)

docker swarm init --advertise-addr $1 | tee | awk '/--token/ {print $2}' > /vagrant/swarm-token

cp /usr/lib/systemd/system/docker.service /usr/lib/systemd/system/docker.service.bavkup

sed -i 's/dockerd/dockerd -H tcp:\/\/0.0.0.0:4243 -H unix:\/\/\/var\/run\/docker.sock/g' /usr/lib/systemd/system/docker.service
cat /usr/lib/systemd/system/docker.service
systemctl daemon-reload
systemctl restart docker.service


#Add Label
cp /etc/default/docker .
echo "DOCKER_OPTS=--label=node.type=manager --label=node.os=linux" >> ./docker
cp ./docker /etc/default/docker

echo  '{ "labels": ["node.type=manager", "node.os=linux"], "insecure-registries" : ["$1:5000"] }' > /etc/docker/daemon.json


systemctl restart docker.service && echo "docker service restarted"

chmod 777 /var/run/docker.sock

#Install docker compose and start weave scope
echo "*********************************************************************"
echo "Installing docker compose"
echo "*********************************************************************"
export DOCKER_COMPOSE_VERSION=1.13.0
curl --insecure -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > ./dc
cp ./dc //usr/local/bin/docker-compose 
chmod +x /usr/local/bin/docker-compose

fi


if [[ "$HOSTNAME" == node* ]]
then

#Add Label
cp /etc/default/docker .
echo "DOCKER_OPTS=--label=node.type=worker --label=node.os=linux" >> ./docker
cp ./docker /etc/default/docker

echo  '{ "labels": ["node.type=worker", "node.os=linux"], "insecure-registries" : ["$1:5000"] }' > /etc/docker/daemon.json


service docker restart && echo "docker service restarted"

chmod 777 /var/run/docker.sock

 echo "*********************************************************************"
 echo "Join Swarm"
 echo "*********************************************************************"
 echo sudo docker swarm join --token `cat /vagrant/swarm-token` $1:2377
 docker swarm join --token `cat /vagrant/swarm-token` $1:2377
fi

echo "*********************************************************************"
echo "DONE $HOSTNAME"
echo "*********************************************************************"