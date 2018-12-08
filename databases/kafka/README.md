# Provision DGraph database in a cluster for high availability

```yaml
by: иÐгü
email: ndru@chimpwizard.com
date: 12.05.2018
version: conception
```

****

The goal of this POC is to get the kafka docker swarm cluster where we can scale it dynamically.


## Prerequisites to run the code

- install [npm](https://docs.npmjs.com/getting-started/what-is-npm)
- install [vagrant](https://www.vagrantup.com/intro/index.html)

### to start the cluster

```shell
npm run up      # To create the servers
npm run deploy  # To deploy the stack in the cluster
```

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

### to clean up your machine

```shell
npm run destroy
```

## Some references while doing this

- https://cwiki.apache.org/confluence/display/KAFKA/Clients#Clients-Node.js
- https://www.npmjs.com/package/kafka-node
- * https://github.com/Blizzard/node-rdkafka
- https://github.com/sutoiku/node-kafka
- https://github.com/LivePersonInc/kafka-java-bridge
- * https://github.com/cainus/Prozess
- https://github.com/dannycoates/franz-kafka
- https://github.com/terrancesnyder/node-kafka
