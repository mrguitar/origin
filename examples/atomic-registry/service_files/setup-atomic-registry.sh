#!/bin/bash

# we need the hostname the web console is coming from to whitelist oauth requests
INSTALL_HOST=${1:-`hostname`}
# we're running this on the host
# the commands will be exec'd in the master container that has the oc client
CMD="docker exec -it"

# Create oauthclient for web console. required for web console to delegate auth
$CMD atomic-registry-master oc new-app --file=/etc/atomic-registry/master/oauthclient.yaml --param=COCKPIT_KUBE_URL=https://${INSTALL_HOST}:9090
# Configure service account for registry to connect to master API
$CMD atomic-registry-master oc create serviceaccount registry
set -x
$CMD atomic-registry-master oadm policy add-scc-to-user privileged -z registry
$CMD atomic-registry-master oadm policy add-cluster-role-to-user system:registry system:serviceaccount:default:registry
# give it a second to finish generating the secrets
sleep 1
TOKEN_NAME=$($CMD atomic-registry-master oc get sa registry --template '{{ $secret := index .secrets 0 }} {{ $secret.name }}')
$CMD atomic-registry-master oc get secret ${TOKEN_NAME} --template '{{ .data.token }}' | base64 -d > /etc/atomic-registry/serviceaccount/token

# write registry shipped config to host and reference bindmounted host file
$CMD atomic-registry cat /config.yml > /etc/atomic-registry/registry/config.yml
echo "REGISTRY_CONFIGURATION_PATH=/etc/atomic-registry/registry/config.yml" >> /etc/sysconfig/atomic-registry

# restart with these changes
systemctl restart atomic-registry.service
