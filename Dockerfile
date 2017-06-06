FROM       python:latest
MAINTAINER Samuel Terburg <sterburg@redhat.com>
USER       0

ENV        APP_SCRIPT=/usr/local/bin/watch.sh
ENTRYPOINT /usr/libexec/s2i/run

RUN  source /opt/rh/rh-python35/enable && \
     pip install certbot certbot-openshift

COPY oc watch.sh control.sh  /usr/local/bin/
