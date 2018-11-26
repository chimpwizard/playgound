
# Using Docker to program the Raspberry Pi

```yaml
by: иÐгü
email: ndru@chimpwizard.com
date: 11.25.2018
version: draft
```

****

The goal of this POC is to have a base  setup to program the raspberry pi but using docker.

## Create a base image

To be sure docker images run on your Pi you need to verify tyour Pi architecture version running:

```sh
cat /proc/cpuinfo
```

And base o nthat you need to make sure your Dockerfile uses a base image that is compatible. eg if your Pi is ARM v6 the list of compatible images are listed here [https://hub.docker.com/u/arm32v6/](https://hub.docker.com/u/arm32v6/).


```dockerfile
FROM arm32v6/alpine:3.6

RUN apk --no-cache add bash python python-dev py-pip build-base curl
RUN pip install RPi.GPIO Flask flask_restful

WORKDIR /var/app

COPY app.py .

CMD ["python", "./app.py"]
```

To run the docker image direcly you need to map the rpio device liket his

```sh
docker container run --device /dev/gpiomem -d chimpwizard/pi:python
```

or

```sh
docker container run --device /dev/gpiomem -d chimpwizard/pi:node
```

## Prerequisites to run the code

- [Raspberry Pi](http://www.raspberry-projects.com/pi/pi-hardware/raspberry-pi-model-b/model-b-io-pins)
- install [npm](https://www.npmjs.com/package/raspberry) on the Pi
- install [docker](https://iotbytes.wordpress.com/setting-up-docker-on-raspberry-pi-and-running-hello-world-container) on the Pi

### to run

```shell
npm run start
```


## Throubleshooting

Few issues I encounter when working on this POC.

### TSL timeout

While trying to run a docker image. the download if the download process gives timeout, follow this link [https://stackoverflow.com/questions/41303784/how-to-pull-layers-one-by-one-in-docker](https://stackoverflow.com/questions/41303784/how-to-pull-layers-one-by-one-in-docker) which basically mention to set the download thread to 1.

Fine the docker.service.d config file usually at Dockerd config location: /etc/systemd/system/docker.service.d/remote-api.conf and updated as follows:

```sh
pi@raspberrypi:~/lab $ sudo cat /etc/systemd/system/docker.service.d/remote-api.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H tcp://127.0.0.1:4243 -H unix:///var/run/docker.sock --experimental --max-concurrent-downloads 1
```

#### References

- https://stackoverflow.com/questions/41303784/how-to-pull-layers-one-by-one-in-docker]

### Docker run doesnt display any output

I faced an issue while running the image on the Pi, after fixing the TSL error image was downloaded correcly but not oputput was showing, while checking the docker events on other terminal

```sh
docker evens
```

Images were exiting with code 139. I came  to understand that this issue is usually a supportability issue on your Pi architecture and the docker image arm version your using.


#### References

- https://stackoverflow.com/questions/52233182/docker-run-does-not-display-any-output
- https://stackoverflow.com/questions/31297616/what-is-the-authoritative-list-of-docker-run-exit-codes
- https://github.com/docker/for-linux/issues/373

### node JS showing "Unknown host QEMU_IFLA type: 40"

#### References

- https://github.com/nodejs/docker-node/issues/873

## Additioal references while doing this

- https://iotbytes.wordpress.com/create-your-first-docker-container-for-raspberry-pi-to-blink-an-led/
- https://www.oreilly.com/library/view/docker-cookbook/9781783984862/ch02s13.html
- https://stackoverflow.com/questions/40591356/enable-docker-remote-api-raspberry-pi-raspbian
- https://iotbytes.wordpress.com/setting-up-docker-on-raspberry-pi-and-running-hello-world-container
- https://www.npmjs.com/package/raspberry
- https://www.raspberrypi-spy.co.uk/2014/07/raspberry-pi-b-gpio-header-details-and-pinout/
- https://thepihut.com/blogs/raspberry-pi-tutorials/27968772-turning-on-an-led-with-your-raspberry-pis-gpio-pins
- http://maxembedded.com/2014/07/using-raspberry-pi-gpio-using-python/
- http://www.raspberry-projects.com/pi/pi-hardware/raspberry-pi-model-b/model-b-io-pins
- http://pi4j.com/usage.html
- http://wiki.mchobby.be/index.php?title=Rasp-Hack-GPIO_Connecteur#Les_broches_27_.C3.A0_40
- http://raspberry.io/projects/view/reading-and-writing-from-gpio-ports-from-python/
- https://www.npmjs.com/package/raspberry
- https://hub.docker.com/u/arm32v7/
- https://blog.codybunch.com/2017/07/14/Docker-on-Raspberry-PI-for-Fan-Control/
- https://tutorials-raspberrypi.com/setup-raspberry-pi-node-js-webserver-control-gpios/
- https://www.npmjs.com/package/rpio
- https://weworkweplay.com/play/raspberry-pi-nodejs/
- https://github.com/tutRPi/Raspberry-Pi-Simple-Web-GPIO-GUI
- https://github.com/tristanls/qemu-alpine
- https://www.npmjs.com/package/onoff
