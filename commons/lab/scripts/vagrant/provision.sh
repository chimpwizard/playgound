#!/bin/bash

platform=$2

echo "******************"
echo "MASTER: $1"
echo "PLATFORM: $platform"
echo "******************"



echo "FOLDER: $PWD"
ls -la
case "$platform" in

    swarm)
        echo "SWARM"
        chmod +x /home/vagrant/scripts/vagrant/swarm/provision.sh
        /home/vagrant/scripts/vagrant/swarm/provision.sh $1
    ;;

    k8s|kubernetes)
        echo "K8s"
        chmod +x /home/vagrant/scripts/vagrant/k8s/provision.sh 
        /home/vagrant/scripts/vagrant/k8s/provision.sh $1
    ;;

    *)
        echo "OTHER"
        
    ;;

esac