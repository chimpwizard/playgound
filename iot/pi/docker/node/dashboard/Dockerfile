# Python Base Image from https://hub.docker.com/r/arm32v7/python/
# FROM arm32v6/python:alpine
# FROM arm32v5/python:2.7.15-jessie
FROM arm32v6/alpine:3.6

RUN apk add --no-cache shadow sudo
RUN groupadd -g 997 gpio && usermod -aG gpio root

RUN apk --no-cache add bash python python-dev py-pip build-base curl gcc make
RUN pip install RPi.GPIO Flask flask_restful
RUN apk add --update nodejs nodejs-npm


ARG user=pi
ARG group=pi
ARG uid=1000
ARG gid=1000
ENV HOME /var/app
RUN groupadd -g ${gid} ${group}
RUN useradd -c "pi user" -d $HOME -u ${uid} -G users,gpio -g ${gid} -m ${user}

WORKDIR ${HOME}

RUN chown -R ${user}:${group} ${HOME}

ENV PORT 8000

USER ${user}

ADD package.json .

#RUN apk add --update git
#RUN git clone https://github.com/tutRPi/Raspberry-Pi-Simple-Web-GPIO-GUI ${HOME}
RUN npm install

ADD . .


CMD ["npm", "start"]