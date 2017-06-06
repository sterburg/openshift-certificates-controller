FROM python:latest
MAINTAINER Samuel Terburg <sterburg@redhat.com>
ENTRYPOINT /usr/local/bin/watch.sh

RUN source /opt/rh/rh-python35/enable && \
    pip install certbot certbot-openshift

COPY oc watch.sh control.sh  /usr/local/bin/
