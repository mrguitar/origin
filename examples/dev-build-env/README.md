# Development Build Environment

A continuous integration and delivery pipeine in a box to help develop docker images. It uses OpenShift v3 and Jenkins.

## Local setup

1. Create an `answers.conf` file with these contents

        [general]
        provider = docker

1. Run this command from the same directory as the answers.conf file. W'ere starting the atomic app to deploy OpenShift and Jenkins master.

        [sudo] atomic run aweiteka/dev-environment

1. If that doesn't work just run these docker commands:

        docker run -d --name jenkins-master-appinfra \
            -p 80:8080 -p 41000:41000 aweiteka/jenkins-master:v1.1
        docker run -d --name origin --privileged --net=host \
            -v /:/rootfs:ro -v /var/run:/var/run:rw \
            -v /sys:/sys:ro -v /var/lib/docker:/var/lib/docker:rw \
            -v /var/lib/openshift/openshift.local.volumes:/var/lib/openshift/openshift.local.volumes openshift/origin start

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

1. Create image stream. We're using centos here. (TODO: automate this in the OSE template)

        $ oc import-image centos --from centos --confirm

1. Create all of the OpenShift resources from the template

        oc create -n test -f https://raw.githubusercontent.com/aweiteka/origin/dev-build-env/examples/dev-build-env/ose-build-template.yaml

1. In the [OpenShift web interface](https://localhost:8443) create a new instance of the template you uploaded.
  1. Login with credentials test/test
  1. Select "test" project
  1. Select "Add to Project", "Browse all templates..." and select the "automated-builds" template.
  1. Select "Edit Parameters", edit the form and select "Create".

1. Copy the Jenkins Job Builder template to your source repository and edit. Run `jenkins-jobs` (TODO: provide jenkins-jobs tool or a way to exec into the jenkins master) to create a whole pile of jenkins jobs. See the results in the [Jenkins web interface](http://localhost).

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
oc delete all -l template=automated-build

# remote trigger (from jenkins job, for example)
# build, deploy, etc.
curl -X POST <url> [--insecure]

# after test promote image with new tag
# from jenkins?
oc tag ${BUILD_IMAGE_NAME}:${BUILD_IMAGE_TAG} ${BUILD_IMAGE_NAME}:<new-tag>

# export local OSE resources as template
oc export all --all -o json --as-template myproject > myproject.json

# import on another openshift server
oc new-app -f myproject.json
```

## Jenkins Master modifications

1. run as root(?) http://stackoverflow.com/questions/29926773/run-shell-command-in-jenkins-as-root-user
1. list plugins
1. need `oc` CLI. Download release binary and copy `oc` to `/usr/bin/oc`, `chmod 755 /usr/bin/oc`.

