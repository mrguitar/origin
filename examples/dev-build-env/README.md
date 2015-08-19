# Development Build Environment

A continuous integration and delivery pipeine in a box to help develop docker images. It uses OpenShift v3 and Jenkins.

## Local setup

1. Create an `answers.conf` file with these contents

        [general]
        provider = docker

1. Run this command from the same directory as the answers.conf file. W'ere starting the atomic app to deploy OpenShift and Jenkins master.

        [sudo] atomic run aweiteka/dev-environment

1. Configure OpenShift. See [reference instructions](https://github.com/openshift/origin#getting-started). Enter the container to use the OpenShift CLI.

        $ sudo docker exec -it origin bash

1. Create a registry

        $ oadm registry --credentials=./openshift.local.config/master/openshift-registry.kubeconfig

1. Login using default credentials.

        $ oc login
        Username: test
        Password: test

1. Create a project

        $ oc new-project test

1. Create image stream. We're using centos here.

        $ oc import-image centos --from centos --confirm

1. Create all of the OpenShift resources from the template

        oc create -n test -f https://raw.githubusercontent.com/aweiteka/origin/dev-build-env/examples/dev-build-env/ose-build-template.yaml

1. In the [OpenShift web interface](https://localhost:8443) create a new instance of the template you uploaded.

1. Copy the Jenkins Job Builder template to your source repository and edit. Run `jenkins-job` to create a whole pile of jenkins jobs. See the results in the [Jenkins web interface](http://localhost).

        jenkins-jobs --conf config/jenkins-jobs.ini --ignore-cache update jenkins-jobs.yaml

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
