#!/bin/sh -x

. /opt/app-root/etc/generate_container_user
. /opt/rh/rh-python35/enable

cat /etc/pki/tls/certs/ca-bundle.trust.crt /run/secrets/kubernetes.io/serviceaccount/ca.crt >/tmp/ca-bundle.crt
export REQUESTS_CA_BUNDLE=/tmp/ca-bundle.crt

TOKEN=`cat /run/secrets/kubernetes.io/serviceaccount/token`
PHASE=${PHASE:-Added}
PROJECT=$1
ROUTE=$2
DOMAIN=$3
TLS=$4
EMAIL=${EMAIL:-sterburg@hoolia.eu}

echo "$PHASE: Project '$PROJECT' with Route '$ROUTE' and Domain '$DOMAIN' has TLS '$TLS'"

case $PHASE in
Added | Updated | Sync )
  ## replace route with temp route to certbot
  oc -n $PROJECT export route/$ROUTE >/tmp/route.old.yaml
  oc -n $PROJECT delete route/$ROUTE
  oc expose pod/$HOSTNAME
  oc expose svc/$HOSTNAME --hostname=$DOMAIN

  ## request certificate
  certbot run -d $DOMAIN \
          --config-dir=/etc/letscencrypt \
          --work-dir=/var/lib/letscencrypt \
          --logs-dir=/var/log/letscencrypt \
          --non-interactive \
          -m $EMAIL \
          --agree-tos \
          -a standalone \
          --tls-sni-01-port 8443 \
          --http-01-port 8080 \
          --preferred-challenges http \
          -i certbot-openshift:installer \
          --certbot-openshift:installer-api-host kubernetes.default \
          --certbot-openshift:installer-namespace $PROJECT \
          --certbot-openshift:installer-token $TOKEN

   ## restore original 'route'
   oc delete route/$HOSTNAME svc/$HOSTNAME
   oc -n $PROJECT create -f /tmp/route.old.yaml
  ;;
Deleted )
  echo "Removing Route, but Removing of certificate is not implemented yet."
  ;;
esac
