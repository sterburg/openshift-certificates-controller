#!/bin/sh -x

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

oc observe routes --all-namespaces --type-env-var=PHASE -a '{ .spec.host } { .spec.tls.termination }' -- ${SCRIPTPATH}/control.sh
