#!/bin/bash
set -e
scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Calls the postgres and rails setup
$scripts_dir/setup-postgres.sh
$scripts_dir/setup-rvm-rails.sh

