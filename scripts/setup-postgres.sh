#!/bin/bash
set -e

# Installs the required packages
yum install wget -y

#
# The commented code was used to create the tarball, It is being kept as a
# future reference
#
# Fetches the postgres source code
# postgres='postgresql-9.6.9'
# wget https://ftp.postgresql.org/pub/source/v9.6.9/$postgres.tar.gz
# tar -xzf $postgres.tar.gz
# cd $postgres
#
# Configures and installs postgres
# ./configure --prefix=/usr
# make world -j $(nproc)
# make install-world -j $(nproc)

# Extracts the compiled version of postgres
cd /tmp
binary=extract-postgres.sh
wget https://s3-eu-west-1.amazonaws.com/flight-direct/$binary
bash $binary

# Creates the postgres user
user=postgres
adduser $user

# Creates the data and log files/dirs
var_dir=/var/postgres
log=/var/log/postgresql.log
mkdir $var_dir
touch $log
chown -R $user $var_dir $log

# Creates the db and starts it
sudo -u $user initdb -D $var_dir/data
sudo -u $user pg_ctl -D $var_dir/data -l $log start

