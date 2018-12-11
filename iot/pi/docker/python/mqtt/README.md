
# Using Docker to program the Raspberry Pi - python - blink a LED pressing a button using a MQTT protocol

```yaml
by: иÐгü
email: ndru@chimpwizard.com
date: 12.10.2018
version: draft
```

****

The goal of this POC is have te RPi to blink a led using a button using python inside docker container and implementing a producer/consumer approch using MQTT protocol

## Prerequisites to run the code

- [Raspberry Pi](http://www.raspberry-projects.com/pi/pi-hardware/raspberry-pi-model-b/model-b-io-pins)
- install [npm](https://www.npmjs.com/package/raspberry) on the Pi
- install [docker](https://iotbytes.wordpress.com/setting-up-docker-on-raspberry-pi-and-running-hello-world-container) on the Pi

### to run

```shell
npm run start:mqtt:python
```

## Additioal references while doing this

- https://bravenewgeek.com/a-look-at-nanomsg-and-scalability-protocols/
- http://www.hivemq.com/blog/how-to-get-started-with-mqtt
- https://learn.adafruit.com/diy-esp8266-home-security-with-lua-and-mqtt/configuring-mqtt-on-the-raspberry-pi
- https://www.youtube.com/watch?v=Pb3FLznsdwI
- http://mosquitto.org/
- https://www.npmjs.com/package/paho-mqtt
- http://mqtt.org/
- http://mosquitto.org/download/
- https://tutorials-raspberrypi.com/raspberry-pi-mqtt-broker-client-wireless-communication/
- https://learn.adafruit.com/diy-esp8266-home-security-with-lua-and-mqtt/configuring-mqtt-on-the-raspberry-pi
