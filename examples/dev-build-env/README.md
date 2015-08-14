# Developer Build Environment

Components:

- OpenShift template
- Jenkins job template

## Bash Notes

```
#!/bin/bash

# OPTIONAL:
# as ose admin (root) add template for all users and projects
oc create -f automated-builds.json -n openshift

# create jenkins master
# see https://github.com/openshift/origin/tree/master/examples/jenkins
oc process -f https://raw.githubusercontent.com/openshift/origin/master/examples/jenkins/jenkins-ephemeral-template.json | oc create -f -

# before we create our image build pipeline...
# we need the base image image stream. Using centos here...
oc create -f https://raw.githubusercontent.com/openshift/origin/master/examples/image-streams/image-streams-centos7.json

# as ose user, process template, parameterize, and create
# this may be done via web UI
oc process -f automated-builds.json -v SOURCE_URI=https://github.com/aweiteka/test-isv-auth.git,BASE_DOCKER_IMAGE=centos,BASE_DOCKER_IMAGE_TAG=centos7,BUILD_IMAGE_NAME=acmeapp,NAME=acme,TEST_CMD='/usr/bin/sleep 10' | oc create -f -


### NOTES:

# delete resources in bulk
oc delete dc,builds,bc,is -l template=automated-build

# remote trigger (from jenkins job, for example)
# build, deploy, etc.
curl -X POST <url> [--insecure]

# cron cmd to update image streams from remote registries
oc import-image <imagestream>

# after test promote image with new tag
# from jenkins?
oc tag ${BUILD_IMAGE_NAME}:${BUILD_IMAGE_TAG} ${BUILD_IMAGE_NAME}:<new-tag>
```
