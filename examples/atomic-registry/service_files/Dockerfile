#FROM registry.access.redhat.com/openshift3/ose
FROM openshift/origin

LABEL name="projectatomic/atomic-registry-install" \
      vendor="Project Atomic" \
      url="https://projectatomic.io/registry" \
      summary="Systemd installation container for Atomic Registry" \
      description="This image installs Atomic Registry on a single host as systemd unit files. It is an open source enterprise registry solution based on the Origin project featuring single sign-on (SSO) user experience, a robust web interface and advanced role-based access control (RBAC)." \
      INSTALL='docker run -it --rm \
                --privileged \
                -v /etc/atomic-registry/:/etc/atomic-registry/ \
                -v /var/lib/atomic-registry/:/var/lib/atomic-registry/ \
                -v /:/host \
                --entrypoint /usr/bin/install.sh \
                $IMAGE' \
      UNINSTALL='docker run -it --rm \
                --privileged \
                -v /:/host \
                --entrypoint /usr/bin/uninstall.sh \
                $IMAGE'

ADD atomic-registry-master.service \
    atomic-registry-console.service \
    atomic-registry.service \
    atomic-registry-master \
    atomic-registry-console \
    atomic-registry \
    oauthclient.yaml \
    setup-atomic-registry.sh \
    /exports/
ADD install.sh uninstall.sh /usr/bin/
ADD registry-login-template.html /container/etc/atomic-registry/
