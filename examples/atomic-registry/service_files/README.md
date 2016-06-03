# Atomic Registry managed by systemd

1. Install

        sudo atomic install aweiteka/atomic-registry-sysd-install <hostname>

1. Start system services

        sudo systemctl start atomic-registry-master.service

1. Setup the registry. This script creates the oauth client so the web console can connect. It also configures the registry service account so it can connect to the API master.

        sudo /usr/bin/setup-atomic-registry.sh <hostname>

## Services

| Service and container name | Role | Configuration | Data |
| -------------------------- | ---- | ------------- | ---- |
| atomic-registry-master | auth, datastore, API | General config, incl auth: /etc/atomic-registry/master/master-config.yaml, Log level: /etc/sysconfig/atomic-registry-master | /var/lib/atomic-registry/etcd |
| atomic-registry | docker registry | /etc/sysconfig/atomic-registry, /etc/atomic-registry/registry/config.yml | /var/lib/atomic-registry/registry |
| atomic-registry-console | web console | /etc/sysconfig/atomic-registry-console | none (stateless) |

## Changing configuration

1. Edit appropriate configuration file(s) on host
1. Restart service via systemd

        sudo systemctl restart <service_name>
