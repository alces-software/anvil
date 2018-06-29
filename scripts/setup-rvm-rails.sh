#!/bin/bash
set -e
scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $scripts_dir/.. >/dev/null

# Install rvm ruby
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable --ruby
source /usr/local/rvm/scripts/rvm

# Installs the gems
gem install bundler
bundle install

# Moves back to the original directory
popd > /dev/null

# Notifies the user they need to source rvm
cat << EOF

Anvil has successfully installed ruby and rails. Either restart your
terminal session or run: \`source /usr/local/rvm/scripts/rvm\`
EOF
