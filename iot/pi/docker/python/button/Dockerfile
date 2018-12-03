# Python Base Image from https://hub.docker.com/r/arm32v7/python/
# FROM arm32v6/python:alpine
# FROM arm32v5/python:2.7.15-jessie
FROM arm32v6/alpine:3.6

RUN apk --no-cache add bash python python-dev py-pip build-base curl
RUN pip install RPi.GPIO Flask flask_restful

WORKDIR /var/app

COPY app.py .

CMD ["python", "./app.py"]