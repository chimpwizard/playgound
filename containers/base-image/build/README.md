# Red Hat 5.0

## References

- https://www.sidorenko.io/post/2016/07/creating-container-base-image-of-centos/
- https://docs.docker.com/engine/userguide/eng-image/baseimages/
- https://github.com/moby/moby/blob/master/contrib/mkimage-yum.sh
- (*) https://github.com/chef/bento
- http://cloudgeekz.com/625/howto-create-a-docker-image-for-rhel.html
- http://phusion.github.io/baseimage-docker/


## Steps

- ./image.sh
- vagrant box remove rhel5 
- vagrant box add rhel5 ./image/rhel5-image.box
- vagrant up
- vagrant ssh worker
- cd /
- tar --numeric-owner --exclude=/proc --exclude=/sys -cvf rhrel5.tar /
- cat ./.vagrant/rhrel5 | docker import - rhrel5
- docker run -i -t .rhrel5 cat /etc/redhat-release
