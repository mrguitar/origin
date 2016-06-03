#!/bin/bash

INSTALL_HOST=${1:-`hostname`}
echo "Installing using hostname ${INSTALL_HOST}"

# write out configuration
openshift start master --write-config /etc/atomic-registry/master \
  --etcd-dir /var/lib/atomic-registry/etcd \
  --public-master ${INSTALL_HOST} \
  --master https://localhost:8443

echo "Copy files to host"

set -x
mkdir -p /etc/atomic-registry/master/site
cp /container/etc/atomic-registry/registry-login-template.html /host/etc/atomic-registry/master/site/.
cp /exports/*.service /host/etc/systemd/system/
cp /exports/atomic-registry-console /host/etc/sysconfig/
cp /exports/atomic-registry-master /host/etc/sysconfig/
cp /exports/atomic-registry /host/etc/sysconfig/
cp /exports/oauthclient.yaml /etc/atomic-registry/master/
cp /exports/setup-atomic-registry.sh /host/usr/bin/setup-atomic-registry.sh
mkdir -p /host/var/lib/atomic-registry/registry
chown -R 1001:root /host/var/lib/atomic-registry/registry

echo "Add serviceaccount token and certificate to registry configuration"
mkdir -p /etc/atomic-registry/serviceaccount
ln /etc/atomic-registry/master/ca.crt /etc/atomic-registry/serviceaccount/ca.crt
echo "default" >> /etc/atomic-registry/serviceaccount/namespace

# create dir for registry config.yml
mkdir /etc/atomic-registry/registry
chown -R 1001:root /etc/atomic-registry/registry

# load updated systemd unit files
chroot /host systemctl daemon-reload

set +x

echo "Updating login template"
sed -i 's/  templates: null$/  templates:\n    login: site\/registry-login-template.html/' /etc/atomic-registry/master/master-config.yaml

echo "Optionally edit configuration file authentication /etc/atomic-registry/master/master-config.yaml,"
echo "and/or add certificates to /etc/atomic-registry/master,"
echo "then start services:"
echo "   sudo systemctl enable atomic-registry-master.service && sudo systemctl start atomic-registry-master.service"
echo "Run the setup script:"
echo "   sudo /usr/bin/setup-atomic-registry.sh ${INSTALL_HOST}"
echo "Launch web console in browser at https://${INSTALL_HOST}:9090"
