#!/bin/bash

# URL of the Launchpad mirror list
MIRROR_LIST=https://launchpad.net/ubuntu/+archivemirrors

# Set to the architecture you're looking for (e.g., amd64, i386, arm64, armhf, armel, powerpc, ...).
# See https://wiki.ubuntu.com/UbuntuDevelopment/PackageArchive#Architectures
ARCH=$1
# Set to the Ubuntu distribution you need (e.g., precise, saucy, trusty, ...)
# See https://wiki.ubuntu.com/DevelopmentCodeNames
DIST=$2
# Set to the repository you're looking for (main, restricted, universe, multiverse)
# See https://help.ubuntu.com/community/Repositories/Ubuntu
REPO=$3

mirrorList=()
# First, we retrieve the Launchpad mirror list, and massage it to obtain a newline-separated list of HTTP mirrors
for url in $(curl -s $MIRROR_LIST | ggrep -Po 'http://.*(?=">http</a>)'); do
  mirrorList+=( "$url" )
done

for url in "${mirrorList[@]}"; do
  (
    # If you like some output while the script is running (feel free to comment out the following line)
    echo "Processing $url..."
    # retrieve the header for the URL $url/dists/$DIST/$REPO/binary-$ARCH/; check if status code is of the form 2.. or 3..
    if curl --connect-timeout 1 -m 1 -s --head "$url/dists/$DIST/$REPO/binary-$ARCH/" | head -n 1 | grep -q "HTTP/1.[01] [23]..";
    then
        echo "FOUND: $url"
    fi
  ) &
done

wait

echo "All done!"
