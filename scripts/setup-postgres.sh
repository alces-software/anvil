#!/bin/bash
set -e

# Installs the required packages
yum install wget readline-devel zlib-devel -y

# Moves to the build dir
dir=/tmp/postgres-build
mkdir -p $dir
cd $dir

# Fetches the postgres source code
postgres='postgresql-9.6.9'
wget https://ftp.postgresql.org/pub/source/v9.6.9/$postgres.tar.gz
tar -xzf $postgres.tar.gz
cd $postgres

# Configures and installs postgres
./configure --prefix=/usr
make world -j $(nproc)
make install-world -j $(nproc)

# Creates the postgres and log
postgres_dir=/usr/share/postgresql
log=/var/log/postgresql.log
user=postgres
adduser $user
touch $log
chown -R $user $log
mkdir -p $postgres_dir
chown -R $user $postgres_dir

# Creates the db and starts it
sudo -u $user initdb -D $postgres_dir/postgres/data
sudo -u $user pg_ctl -D $postgres_dir/postgres/data -l $log start

