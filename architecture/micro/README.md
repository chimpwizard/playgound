
# micro-Frontends, micro-Services & micro-Container (micro-x)

```yaml
by: иÐгü
email: ndru@chimpwizard.com
date: 11.14.2018
version: conception
```

****

The goal of this POC is create an application using micro front end and micro services on the smallest possible container.

## Proposed Design

Microservices has been very popular, what usually happens is that you have a nice microservice architecture on the back end unsing technologies like kubernetes or docekr swarm but the front end become a monolithic appproach. The goals of microservices is to faciliate agine development and continuos deployment, the idea is to make sure you can do the same across all the layers on your application.

### The problem

For the purpose of this POC we will use angular7/elements which is an implementation of webcomponents and nodejs on the back end to build a simple application.

The application model is represented by the following diagram.

![""](images/model.png)

### Challenges

When you breakdown your application in micro elements (services or front end) you are in a different territory b/c as the number of services and front ends components grow you will need other tools/techniques to manage the complexity. Yes it is much more complex working with this approach but what we are looking for while doing this are: (It these are not the goal/requirements you have avoid the use of micro-x)

- Manageable chuncks of code that can be deployable on regular basis.. close to hours instead of months. Final goal is that every code changes can go to production automatically.
- Easy to split a work between a diverse team and avoid merge conflicts
- Take advantage of feature toggling, blue/green deployments and A/B testing in a more manegable way.
- Addopt an agile methoology.

These are some of challenges you will face while transitioning to micro-x:

- Bugs/Issues throubleshooting. The micro-x has a big impact on how the developers and support teams throubleshoot issues.
- CICD platforms. When dealing with houndresds of micro-x you need additional tools to facilitate the configuration of your CICD stack. It definitelly cannot be a manual process.
- Holistic view of the system is difficult to follow.
- Additional extra tools are required.
- The CICD needs to be part of your design as well new "Actors" like the support team needs to be part of your analisys.
- Latency and asyncronous processing play a big role on this architecutre.
- Loggin and Monitoring tools.
- Several patterns need to be consider:
  - Circuit break, what if a service we depend on is not responding
  - Service discovery
  - Web components
  - Bounded context
  - Service aggregations
  - Transactions, how to deal with the asyncronous
  - Version control
  - Artifacts control
  - Caching
  - A lot of automatic testing (unit and functional) is needed

### Breakingdown the pieces

THe domain model is very simple, We have a collection of Books and the Authors of those Books.

Now lets get more real requirements (we will keep it simple and short):

- Just the author or the publisher can edit the book profile
- Author need to know the acceptance of the book using a rankins approach.
- Buyers will be able to search the library based on some criteria.

### The architecture

### to run

```shell
npm run provision
npm run build
npm run deploy
```

## Some references while doing this

- https://microservices.io/
- https://micro-frontends.org/
- https://medium.com/@gilfink/why-im-betting-on-web-components-and-you-should-think-about-using-them-too-8629396e27a
- https://medium.com/@tomsoderlund/micro-frontends-a-microservice-approach-to-front-end-web-development-f325ebdadc16
- https://www.softwarearchitekt.at/post/2018/05/04/microservice-clients-with-web-components-using-angular-elements-dreams-of-the-near-future.aspx
- https://domainlanguage.com/ddd/
- https://martinfowler.com/bliki/BoundedContext.html



## Additional improvements

- xxx