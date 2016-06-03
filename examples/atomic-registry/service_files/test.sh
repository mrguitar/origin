#!/bin/bash

set -x

TEST_IMAGE=atomic-registry-install
HOST=${1:-"localhost"}

docker build -t ${TEST_IMAGE} .
atomic install ${TEST_IMAGE} ${HOST}
systemctl start atomic-registry-master.service
sleep 10
sudo /usr/bin/setup-atomic-registry.sh ${HOST}
