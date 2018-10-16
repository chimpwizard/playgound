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
        docker stack deploy --compose-file ./sample/swarm/docker-compose.yml hw
    ;;

    k8s|kubernetes)
        echo "K8s"
        #kubectl apply -f ./sample/k8s/
        kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
    ;;

    *)
        echo "OTHER"
        
    ;;

esac