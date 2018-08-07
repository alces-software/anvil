#!/bin/bash
# Creates the `git` directory in anvils public dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
target_dir="$DIR/../public/git"
mkdir -p $target_dir

# List of git repos that will part of the snapshot
repos=(clusterware-handlers clusterware-sessions clusterware-services \
       clusterware-storage gridware-packages-main packager-base \
       gridware-depots)

# Downloads the git repo and creates a tarball
for i in "${repos[@]}"; do
  git clone https://github.com/alces-software/$i.git /tmp/repos/$i
  tar --warning=no-file-changed -C /tmp/repos/$i -czf $target_dir/$i.tar.gz .
done
