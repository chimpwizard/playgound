FROM nodered/node-red-docker:rpi-v6

COPY package.json /data/.
RUN cd /data; npm install

COPY data/ /data/ 