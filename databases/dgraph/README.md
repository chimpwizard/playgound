# Provision DGraph database in a cluster for high availability

```yaml
by: иÐгü
email: ndru@chimpwizard.com
date: 10.13.2018
version: draft
```

****

The goal of this POC is to get the DGRAPH database on a docker swarm cluster where we can scale the database dynamically.

When checking how to run dgraph on a container using the DGRAPH documentation  you notice that the defined HA configuration is very static becase the number of instances of the cluster are individual services declared in the  docker-compose YAML files.

I want to present an alternative that is more flexible, dynamic and easirer to scale.

I want to be able to scale the number of master and worker nodes using the swarm or kubernetes capabilities and make the cluster to addapt to that instead of reconfiguring the YAML files to achieve that. I hope the DGraph core team include something like this its core components.

The source code can be found [here](https://github.com/chimpwizard/playgound/tree/master/databases/dgraph).


## Proposed Architecture

Assuming you already read [DGraph Get Started Guide](https://docs.dgraph.io/get-started/).

The dgraph architecture requries some zero and server nodes. What is important to notice  is that by design each instance in the cluster needs to be fully identitied, meaning fully accesble by hostname name. This is what makes difficult the scalling.

The proposed architecture is as follows.

(**SOME IMAGE TBD**)

## The implementation

The first thing we need to do is to extend the dgraph docker image, the reson is that the current implementation doesnt provide a way to change the servername at start up command, this is what is going to allow us to configure dgraph accorly to add additional capabilities to override the default behaviour.

```dockerfile
FROM dgraph/dgraph:latest

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install sudo apt-utils net-tools && \
    apt-get -y install gettext-base

ENV TASK_SLOT=1

ADD run.sh .
ADD wait-for-it.sh .
ADD redi.sh .

ENTRYPOINT ["/dgraph/run.sh"]
```

The magic happens on the run.sh file where basically the trick is to change the --peer and --zero params before launching the service.

Lets go over the most important pieces

Initially all is does its to cature the incoming parameters and identify what type of service is oging to be launched (zero or server), the idea here is to keep the commandd as close as possible to the proposed solution in the dgraph documentation.

The command looks like this.

```bash
command: --command zero --my $$HOSTNAME:508$$TASK_SLOT --replicas 3 --idx $$TASK_SLOT  -o $$TASK_SLOT --peer zero:5081  -v 2
```

$$HOSTNAME, $$TASK_SLOT  are place holders automatically updated by docker swarm command, the double dollar symbol prevent docker cli to replace those values with environment variables.

```bash
#!/bin/bash

echo "********************************************************************************** "
echo "HOSTNAME: ${HOSTNAME}"
echo 'num of args: '$#
i=0
xxargs=""
for arg in "$@"; do
   #echo 'arg: '$arg;
   if [ $i -ge "0" ]; then
      xxargs=$xxargs" "$arg
   fi;
   i=$((i + 1))
done

newargs=""
while [[ $# -gt 0 ]]
do
    key="$1"
    #echo "$key"
    case $key in

        -h|--help)
        help="true"
        shift # past argument
        ;;

        -c|--command)
        command="$2"
        shift # past argument
        ;;


        --default)
        ;;

        *)
        echo "$key=\"$2\""
        key2=$(echo $key|tr --delete -)
        eval "export $key2=\"$2\""

        if [ "$key2" == "peer" ]; then
            echo "*** ZERO NODE"
        else
            if [ "$key2" == "zero" ]; then
                echo "*** SERVER NODE"
            else
                newargs=$newargs" $key $2"
            fi;
        fi;
        shift
        ;;
    esac
    shift # past argument or value
done

if [ "$help" == "true" ]; then
    echo "********************************************************************************** "
    echo ""
    echo "dgraph [OPTIONS]"
    echo " "
    echo "OPTION:"
    echo ""
    echo "  -h | --help             : This Help"
    echo "  -c | --command          : "
    echo ""
    echo "********************************************************************************** "
    exit 0;
fi
```

Then the code relies on the in-memory redis database to be able to store what node is the first zero instace which becomes the leader. This piece of code just makes sure that the redis instance is already up before proceding.

```bash
echo "*** Wait for redis to be up"
/dgraph/wait-for-it.sh redis:6379 -t 60
```

If the container  correspond to a zero instance. It checks if that is the first one, the first instacne makes sure it get registered in redis so the following containers can use its ip as the zero master or peer server.

Since all container can start in parallel it is important to check if redis record is already stored, if record is found the --zero or the --peer parameters get overriden.

```bash
if [ "$command" == "zero" ]; then
    if [ "$TASK_SLOT" = "1" ]; then
        echo "FIRST ZERO";
        port=$(echo  "$peer"|awk '{split($0,p1,":")system("echo "p1[2]) }')
        echo "$(hostname -i):$port" | /dgraph/redi.sh -H redis -P 6379 -s zero
    else
        echo "OTHER ZERO";

        zz=$(/dgraph/redi.sh -H redis -P 6379 -g zero)
        while [ "$zz" == "" ]
        do
            zz=$(/dgraph/redi.sh -H redis -P 6379 -g zero)
            echo "**** Sleep 10s ...[$error]"
            sleep 10s
        done


        echo "*** Record found $zz"
        peer="$zz"
        newargs=$newargs" --peer $peer"
        echo "*** Wait for $peer to be up"
        /dgraph/wait-for-it.sh $peer -t 30

    fi;
fi;
```

The server containers follow similar rules and checks that redis and the zero node is up.

```bash
if [ "$command" == "server" ]; then


    zz=$(/dgraph/redi.sh -H redis -P 6379 -g zero)
    while [ "$zz" == "" ]
    do
        zz=$(/dgraph/redi.sh -H redis -P 6379 -g zero)
        echo "**** Sleep 10s ...[$error]"
        sleep 10s
    done
    echo "*** Record found $zz"
    zero="$zz"
    newargs=$newargs" --zero $zero"
    echo "*** Wait for $zero to be up"
    /dgraph/wait-for-it.sh $zero -t 30
fi;
```

Then the final command is rewritten and the container can be launched.

```bash
command="dgraph $command $newargs"


echo "COMMAND: `echo ${command}|envsubst`"
env
echo "********************************************************************************** "

echo $command|sh -

```

## Prerequisites to run the code

- install [npm](https://docs.npmjs.com/getting-started/what-is-npm)
- install [vagrant](https://www.vagrantup.com/intro/index.html)

### to start the cluster

```shell
npm run up      # To create the servers
npm run deploy  # To deploy the stack in the cluster
```

... then go to [http://172.10.10.20:8000](http://172.10.10.20:8000) and update the connection to
**172.10.10.20:8080** to point to the database api. The portainer console can be located at [http://172.10.10.20:9000](http://172.10.10.20:9000) for this use user **"admin"** and password **"password"**.

All server instances listen on port 8080, this takes advantage of the embeded load balancer that comes with docker swarm.

### how to scale up

If you notice the docker-compose code already is making use of the replicas property in both services zero and server.

```yaml
    deploy:
      replicas: 3
```

This small snippet illustrates how to scale the servers to 5 nodes.

```bash
npm run console                     # To get into the console box
docker service scale dg_server=5    # To scale to 5 server dgraph instacnes
docker service ls                   # To verify the instances running

# To check dgraph metrics
curl http://172.10.10.20:8080/debug/vars | python -m json.tool | less
```

### to clean up your machine

```shell
npm run destroy
```

## Some references while doing this

- https://gist.github.com/wpscholar/a49594e2e2b918f4d0c4
- https://www.calebwoods.com/2015/05/05/vagrant-guest-commands/
- https://portainer.readthedocs.io/en/stable/configuration.html
- https://docs.docker.com/engine/reference/commandline/service_create/#create-services-using-templates
- https://github.com/crypt1d/redi.sh
- https://github.com/dgraph-io/dgraph-js-http
- https://github.com/helm/helm/blob/master/docs/charts.md

## Additional improvements

- Cover what would be the code to support a kubernetes cluster.






<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-43465642-1"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-43465642-1');
</script>