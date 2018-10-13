# Use DGraph on a HA Cluster

The goal of this POC is to run DGRAPH database on a cluster (swarm or kubernetes) where we can scale the database dynamically.

When checking how to run dgraph on a container using the DGRAPH documentation  you notice that there is not a real HA configuration defined int he docker-compose or kubernetes files, instead is a very static configuration because there is a specific number of nodes declared on the files.

I want to present an alternative that is more flexible, dynamic and easirer to scale. 

I want to be able to scale the number of master and worker nodes using docker swarm or kubernetes capabilities and make the cluster to addapt to that instead of reconfiguring the YAML files to achieve that. I hope the DGraph core team include something like this in the core docker image.

The code for this POC can be found [Here](http://github.com/chimpwizard/playground/dgraph/README.md)

## Proposed Architecture

Assuming you arelady read [DGraph Get Started Guide](https://docs.dgraph.io/get-started/).

The dgraph architecture requries some masters (aka zero servers) and workers (aka server nodes). What is important to notice  is that by design each instance in the cluster needs to be fully identitied, meaning fully accesble by server name. This is what makes difficult the dynamic scalling.

The proposed architecture is as follows.


**SOME IMAGE




## The implementation

The first thing we need to do is to extend the dgraph docker image, the reson is that the current implementation doesnt provide a way to change the servername at start up command, this is what is going to allow us to configure dgraph accorly.

The dockefile extends the  dgraph image and add basic capabilities and some scripts to override the default behaviour.

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

The magic happens on the run.sh file where basically the trick is to change the --peer and --zero params supported by the capabilities of a redis in memory database.

Lets go over the most important pieces

Initially all is does its to cature the incoming parameters.. the idea here is to keep the commandd as close as possible to the proposed solution in the dgraph documentation.

This piece of the code does two things;. First capture in the type or service needs to be executed (zero or server), then capture the additional standrar parameters.

The idea is to be able to process this piece of the start command

```bash
command: --command zero --my $$HOSTNAME:508$$TASK_SLOT --replicas 3 --idx $$TASK_SLOT  -o $$TASK_SLOT --peer zero:5081  -v 2
```

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
            if [ "$TASK_SLOT" != "1" ]; then
                #newargs=$newargs" $key $2"
                echo "*** OTHER ZERO NODE"
            else    
                echo "*** FIRST ZERO NODE"
            fi;
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

Then the code relies on redis to be able to store what node is the first zero instace which becomes the leader, additionally to that in order to be resilent it checks that redis is up.

```bash
echo "*** Wait for redis to be up"
/dgraph/wait-for-it.sh redis:6379 -t 60
```

If the container  is the master or zero instance. It checks if that is the first one or the other ones, here is where the first instacne makes sure it get registered in redis so the following containers can use its ip as the zero master or peer server.

Since all container can start in parallel it is important to check if redis record is already stored, if record is found the --zero or the --peer parameters we overriden.

```bash
if [ "$command" == "zero" ]; then
    if [ "$TASK_SLOT" = "1" ]; then
        echo "FIRST ZERO";
        port=$(echo  "$peer"|awk '{split($0,p1,":")system("echo "p1[2]) }')
        #echo "$peer" | /dgraph/redi.sh -H redis -P 6379 -s zero
        #echo "$HOSTNAME:$port" | /dgraph/redi.sh -H redis -P 6379 -s zero
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

The server containers follow similar rules and checksthat redis and the master/zero node is up.

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

Then the final command is rewrited and the container can be started.

```bash
command="dgraph $command $newargs"


echo "COMMAND: `echo ${command}|envsubst`"
env
echo "********************************************************************************** "

echo $command|sh -

```

## Prerequisites to run the code

- install vagrant


### Start the cluster

```shell
npm run up
npm run deploy
```

... then go to [http://172.10.10.20:8000](http://172.10.10.20:8000)

## Some references while doing this

- https://gist.github.com/wpscholar/a49594e2e2b918f4d0c4
- https://www.calebwoods.com/2015/05/05/vagrant-guest-commands/
- https://portainer.readthedocs.io/en/stable/configuration.html
- https://docs.docker.com/engine/reference/commandline/service_create/#create-services-using-templates

## Credits

иÐгü: ndru@chimpwizard.com