#!/bin/bash
scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Installs postgres if it is missing
if ! which postgres 2>&1 >/dev/null; then
  $scripts_dir/setup-postgres.sh
fi

# Ensures the profile has been sourced
source ~/.bashrc

# Sets the rails environment to be snapshot
if ! [[ -z "RAILS_ENV" ]]; then
  echo "export RAILS_ENV=snapshot" >> ~/.bashrc
  source ~/.bashrc
fi

# Installs the gems
cd $scripts_dir/..
bundle install --without development --with default snapshot

# Sets up systemd integration for anvil
systemd=/usr/lib/systemd/system/anvil.service
cat << SYSTEMD > $systemd
[Unit]
Description=Runs the anvil cache server
Requires=network.target
Requires=postgresql.service

[Service]
Type=simple
ExecStart=/bin/bash $scripts_dir/start-anvil.sh

TimeoutSec=30

[Install]
WantedBy=multi-user.target
SYSTEMD
systemctl daemon-reload

# Prints the ip information to the screen, this is for the users benefit
# as it displays the IP of the node. It's up to the user if they uses it
# in the snapshot
ip a

# Preforms the snapshot
# It will either prompt for the IP (OR use the env var if set)
rake packages:snapshot

# Starts the server
systemctl enable anvil
systemctl start anvil

# Notifies the install has completed
cat << MSG
Successfully installed 'Anvil' server
MSG

