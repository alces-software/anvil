#!/bin/bash
source /etc/profile.d/flight-direct.sh
source $FL_ROOT/etc/runtime.sh
anvil_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd $anvil_dir
bundle exec rails server -p 80 -b 0.0.0.0 -e snapshot
