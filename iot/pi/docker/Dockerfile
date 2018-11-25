# Python Base Image from https://hub.docker.com/r/arm32v7/python/
FROM arm32v5/python:2.7.13-jessie

WORKDIR /var/app

COPY app.py .

# Intall the rpi.gpio python module
RUN pip install --no-cache-dir rpi.gpio

# Trigger Python script
CMD ["python", "./app.py"]