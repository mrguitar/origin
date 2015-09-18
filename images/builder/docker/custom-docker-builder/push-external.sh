#!/bin/bash
set -o pipefail
IFS=$'\n\t'

DOCKER_SOCKET=/var/run/docker.sock

# Custom build script to promote an image from one registry to another
# Pull an image, tag and push to a registry
#
# ENV variables:
#   PULL_REGISTRY required
#   PULL_IMAGE    required
#   PULL_TAG      default:latest (optional)
#   PUSH_REGISTRY required
#   PUSH_IMAGE    default: PULL_IMAGE (optional)
#   PUSH_TAG      default:latest (optional)
#

if [ ! -e "${DOCKER_SOCKET}" ]; then
  echo "Docker socket missing at ${DOCKER_SOCKET}"
  exit 1
fi

if [ -z "${PUSH_TAG}" ]; then
  PUSH_TAG=latest
fi
if [ -z "${PULL_TAG}" ]; then
  PULL_TAG=latest
fi
if [ -z "${PUSH_IMAGE}" ]; then
  PUSH_IMAGE=${PULL_IMAGE}
fi

PULL="${PULL_REGISTRY}/${PULL_IMAGE}:${PULL_TAG}"
PUSH="${PUSH_REGISTRY}/${PUSH_IMAGE}:${PUSH_TAG}"
echo "DEBUG: Pull command '${PULL}'"
echo "DEBUG: Push command '${PUSH}'"

docker pull "${PULL}"

if [[ -d /var/run/secrets/openshift.io/push ]] && [[ ! -e /root/.dockercfg ]]; then
  cp /var/run/secrets/openshift.io/push/.dockercfg /root/.dockercfg
fi

if [[ -d /var/run/secrets/openshift.io/pull ]] && [[ ! -e /root/.dockercfg ]]; then
  cp /var/run/secrets/openshift.io/pull/.dockercfg /root/.dockercfg
fi

docker tag "${PULL}" "${PUSH}"

if [ -n "${PULL_IMAGE}" ] || [ -s "/root/.dockercfg" ]; then
  # in RHEL we're prompted with warning about pushing to public registry
  docker push --force=true "${PUSH}"
fi
