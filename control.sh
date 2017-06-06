#!/bin/sh -x

. /opt/rh/rh-python35/enable

TOKEN=`cat /run/secrets/kubernetes.io/serviceaccount/token`
PHASE=${PHASE:-Added}
PROJECT=$1
ROUTE=$2
DOMAIN=$3
TLS=$4

echo "$PHASE: Project '$PROJECT' with Route '$ROUTE' and Domain '$DOMAIN' has TLS '$TLS'"

case $PHASE in
Added | Updated | Sync )
  certbot run -d $DOMAIN \
          -i certbot-openshift:installer \
          --certbot-openshift:installer-api-host kubernetes.default \
          --certbot-openshift:installer-namespace $PROJECT \
          --certbot-openshift:installer-token $TOKEN
  ;;
Deleted )
  echo "Removing Route, but Removing of certificate is not implemented yet."
  ;;
esac
