#!/bin/bash
set -euo pipefail

# Usage: docker_build.sh <tag_name:version>
#
# Build the rCRUX docker image.  Provide the tag name of the image that will be
# built.  The "version" part of the tag name should match the
# org.opencontainers.image.version label in the Dockerfile.
#
# Example: time sudo bash inst/docker/docker_build.sh rcrux:1d371a9-1
#
if [ "$#" -ne 1 ]; then
  printf "Usage: %s <tag_name>\n" "$(basename "$0")" >&2
  printf "  Build the rCRUX Docker image.  Run this script from the root of the git repository.\n" >&2
  exit 1
fi

tagname="${1}"

docker build \
  --build-arg BUILD_DATE=$(date --iso-8601=seconds) \
  --build-arg GIT_REVISION=$(git rev-parse HEAD) \
  --progress=plain \
  --network=host \
  --platform=linux/amd64 \
  -t "${tagname}" \
  .
