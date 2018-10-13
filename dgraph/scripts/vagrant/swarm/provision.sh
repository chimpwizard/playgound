#!/bin/bash

get_distribution() {
	lsb_dist=""
	# Every system that we officially support has /etc/os-release
	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi
	# Returning an empty string here should be alright since the
	# case statements don't act unless you provide an actual value
	echo "$lsb_dist"
}


module="install-docker"
lsb_dist=$( get_distribution )
lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

echo "FOLDER: $PWD"
case "$lsb_dist" in

    ubuntu)
        echo "UBUNTU"
        /vagrant/scripts/vagrant/swarm/ubuntu/provision.sh $1
    ;;

    debian|raspbian)
        echo "DEBIAN"
    ;;

    centos)
        echo "CENTOS"
        /vagrant/scripts/vagrant/swarm/centos/provision.sh $1
    ;;

    rhel|ol|sles)
        echo "RHEL"
        /vagrant/scripts/vagrant/rhel/centos/provision.sh $1
    ;;

    *)
        echo "OTHER"
        /vagrant/scripts/vagrant/swarm/other/provision.sh $1
    ;;

esac



