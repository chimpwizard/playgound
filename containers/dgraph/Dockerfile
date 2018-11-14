FROM dgraph/dgraph:latest

LABEL maintainer=ndru@chimpwizard.com \
      description="Add additional features to dgraph base image"

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install sudo apt-utils net-tools && \
    apt-get -y install gettext-base

ENV TASK_SLOT=1

ADD run.sh .
ADD wait-for-it.sh .
ADD redi.sh .

ENTRYPOINT ["/dgraph/run.sh"]