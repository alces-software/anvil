#!/bin/bash

package_name='anvil'

if [ -f ./${package_name}.zip ]; then
  echo "Replacing existing ${package_name}.zip in this directory"
  rm ./${package_name}.zip
fi

temp_dir=$(mktemp -d /tmp/${package_name}-build-XXXXX)
anvil_dir="$temp_dir/data/opt/anvil"

mkdir -p $anvil_dir

pushd .. > /dev/null
git archive HEAD | tar -x -C "${temp_dir}"/data/opt/anvil
popd > /dev/null

pushd "${temp_dir}" > /dev/null
zip -r ${package_name}.zip *
popd > /dev/null

mv "${temp_dir}"/${package_name}.zip .

rm -rf "${temp_dir}"
