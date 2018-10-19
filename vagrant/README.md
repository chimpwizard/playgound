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

(**SOME IMAGE TBD**)

## The implementation

(TBD)

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

## Additional improvements

- Test provisioning scripts for other OS != ubuntu.