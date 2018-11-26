# Python Base Image from https://hub.docker.com/r/arm32v7/python/
# FROM arm32v6/python:alpine
# FROM arm32v5/python:2.7.15-jessie
FROM arm32v6/alpine:3.6

RUN apk add --no-cache shadow sudo
RUN groupadd -g 997 gpio && usermod -aG gpio root

RUN apk --no-cache add bash python python-dev py-pip build-base curl gcc make
RUN pip install RPi.GPIO Flask flask_restful
RUN apk add --update nodejs nodejs-npm

WORKDIR /var/app
ADD package.json .
RUN npm install
ADD app.js .

CMD ["node", "./app.js"]