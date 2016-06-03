#!/bin/bash

set -x

REMOVE_DATA=false
if [ $1 == "--remove-data" ] ; then
  REMOVE_DATA=true
fi

SERVICES=(atomic-registry-master.service atomic-registry-console.service atomic-registry.service)
for SVC in "${SERVICES[@]}"
do
  chroot /host systemctl stop ${SVC}
  chroot /host systemctl disable ${SVC}
done

CONFDIRS=(/etc/atomic-registry
      /etc/sysconfig/atomic-registry-master
      /etc/systemd/system/atomic-registry-master.service
      /etc/sysconfig/atomic-registry
      /etc/systemd/system/atomic-registry.service
      /etc/sysconfig/atomic-registry-console
      /etc/systemd/system/atomic-registry-console.service
      /usr/bin/setup-atomic-registry.sh)

DATADIRS=(/var/lib/atomic-registry)

echo "Removing configuration files..."
for CONFDIR in "${CONFDIRS[@]}"
do
  chroot /host rm -rf ${CONFDIR}
done

chroot /host systemctl daemon-reload

if [ $REMOVE_DATA == "true" ] ; then
  echo "Removing data..."
  for DATADIR in "${DATADIRS[@]}"
  do
    chroot /host rm -rf ${DATADIR}
  done
fi

set +x
IMAGES=(openshift/origin openshift/origin-docker-registry cockpit/kubernetes)

echo "Uninstallation complete."
echo "Images have not been removed. To remove them manually run:"
echo "sudo docker rmi ${IMAGES[*]}"
