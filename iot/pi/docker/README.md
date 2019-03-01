
# Using Docker to program the Raspberry Pi

```yaml
by: иÐгü
email: ndru@chimpwizard.com
date: 11.25.2018
version: draft
```

****

The goal of this POC is to have a base  setup to program the raspberry pi but using docker. This is very useful to facilitate the update of a new version of your code running on a ARM device.

The source code can be found [here](https://github.com/chimpwizard/playgound/tree/master/iot/pi/docker)

## Create a base image

To be sure docker images run on your Pi you need to verify the Pi architecture version.
Run this command to check:

```sh
cat /proc/cpuinfo
```

And base on that you need to make sure your Dockerfile uses a base image that is compatible. 
For example  if your Pi is ARM v6 the list of compatible images are listed here [https://hub.docker.com/u/arm32v6/](https://hub.docker.com/u/arm32v6/).

```dockerfile
FROM arm32v6/alpine:3.6

RUN apk --no-cache add bash python python-dev py-pip build-base curl
RUN pip install RPi.GPIO Flask flask_restful

WORKDIR /var/app

COPY app.py .

CMD ["python", "./app.py"]
```

To run the docker image direcly you need to map the rpio device like this

```sh
docker container run --device /dev/gpiomem -d chimpwizard/pi-blink:python
```

or this for node. 
>NOTE: The volume might be differen. I found out this by throubleshooting a Read-Only error.

```sh
docker container run --device /dev/gpiomem -d -v /sys/class/gpio/export:/sys/class/gpio/export -v /sys/devices/platform/soc/20200000.gpio/gpiochip0/gpio:/sys/devices/platform/soc/20200000.gpio/gpiochip0/gpio chimpwizard/pi:node
```

## Prerequisites to run the code

- [Raspberry Pi](http://www.raspberry-projects.com/pi/pi-hardware/raspberry-pi-model-b/model-b-io-pins)
- install [npm](https://www.npmjs.com/package/raspberry) on the Pi
- install [docker](https://iotbytes.wordpress.com/setting-up-docker-on-raspberry-pi-and-running-hello-world-container) on the Pi
- install [docker-compose](https://docs.docker.com/compose/install/)

### to run

```shell
npm run start
```

## Additional samples

This POC also contains several samples in python and node.

### python

- [blink](python/blink/README.md): This turns ON and OFF a lead on port 18
- [button](python/button/README.md): This turns ON and OFF a lead on port 18 based on a button configured as input on port 26.
- [mqtt](python/mqtt/README.md): Client/Subcribe using mqtt protocol

### nodejs

- [blink](node/blink/README.md): This turns ON and OFF a lead on port 18
- [button](node/button/README.md): This turns ON and OFF a lead on port 18 based on a button configured as input on port 26.
- [dashboard](node/dashboard/README.md): This is forked from [Simple Web GPIO](https://github.com/tutRPi/Raspberry-Pi-Simple-Web-GPIO-GUI), there is a small bug ont he code tht is fixed.
- [mqtt](node/mqtt/README.md): Client/Subcribe using mqtt protocol
- [red](node/red/README.md): THis is a nodered sample running inside docker on the Pi.

## Throubleshooting

Few issues I encounter when working on this POC.

### Turning a LED from command line

I found usieful this command to test the Pi is able to turn ON/OFF a lead

```sh
echo "4" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio4/direction
echo "1" > /sys/class/gpio/gpio4/value
sleep 1
echo "4" > /sys/class/gpio/unexport
```


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

TWhat I found about this was if you are building your image that does npm install for node modules on a non raspberry pi it will failt which is a bummer but if you build it on a pi then push the image to your repo it will work just fine.

So the lesson learn here is you need to have a pi as part of yoru CICD workflow.



#### References

- https://github.com/nodejs/docker-node/issues/873

### Raspberry Pi GPIO folder readonly issue

This issue wasn't documented anywere as far as I know. I fixed adding the volume on the host that links the GPIO PINS.

```
docker run .... -v /sys/class/gpio/export:/sys/class/gpio/export -v /sys/devices/platform/soc/20200000.gpio/gpiochip0/gpio:/sys/devices/platform/soc/20200000.gpio/gpiochip0/gpio 
```

### Not able to access raspberry pi docker instance using remote api calls

This is usually because the port is closed. 

Check what is running on the port

```sh
sudo netstat -tln
sudo netstat -lptu
```


Check if port is open to the outside

```sh
nmap -p [PORT] [IP]
```

TO fix it run 

```sh
sudo apt-get install ufw
sudo ufw allow 22
sudo ufw allow [PORT]
sudo ufw enable
sudo reboot
```

#### References

- https://raspberrypi.stackexchange.com/questions/79434/edit-iptables-to-open-a-port-the-safest-and-easiest-way-nano
- https://www.raspberrypi.org/forums/viewtopic.php?t=104728
- https://raspberrypi.stackexchange.com/questions/69123/how-to-open-a-port


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
- * https://www.npmjs.com/package/raspberry
- https://hub.docker.com/u/arm32v7/
- https://blog.codybunch.com/2017/07/14/Docker-on-Raspberry-PI-for-Fan-Control/
- * https://tutorials-raspberrypi.com/setup-raspberry-pi-node-js-webserver-control-gpios/
- https://www.npmjs.com/package/rpio
- https://weworkweplay.com/play/raspberry-pi-nodejs/





<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-43465642-1"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-43465642-1');
</script>