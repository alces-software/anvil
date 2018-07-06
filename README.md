# Deployment to Dokku

For the first time:

 - Create a Dokku app and linked Postgres service
 - Override the autodetection of buildpacks, which gets confused by the presence of a 
 `Dockerfile`:
 `dokku config:set <app> BUILDPACK_URL=https://github.com/heroku/heroku-buildpack-ruby.git`
 - Run `dokku run <app> rake db:setup` to initialise the database
 - Run `dokku run <app> rails console` and create an `alces` user. You'll need to assign
 a `flight_id` that matches the `alces` user on the Flight SSO service you'll be using.
   - Or, if you can assume that `alces` will never actually log in, you can use an empty
   `flight_id`.
 - Set a secret for creating JSON Web Tokens:
     `dokku config:set <app> JSON_WEB_TOKEN_SECRET=<somesecret>`
   Note, this should be shared with the Flight SSO service!
 - Set environment variables for `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and
 `AWS_FORGE_ROOT_BUCKET` so Anvil can talk to S3
 - Add Git remote and push to Dokku
 - Add a domain e.g. `dokku domains:add <app> domain.alces-flight.com`
 - Set up SSL. I've used the `dokku-letsencrypt` plugin for now at least:
     `dokku letsencrypt <app>`
 - Then you can prime the database with delicious Flight content using the two Rake tasks
 provided for the purpose:
   - `dokku run <app> rake gridware:update`
   - `dokku run <app> rake customizer:update`
      - Don't be alarmed by the big red mentions of `ROLLBACK` in the output. That's
      Rails's way of telling you it's in the `create` part of `first_or_create` (AFAICT).
      
Subsequent times: TBC but something like push, migrate, ???, profit (is it clever enough
to migrate automatically?)

## Updating customizers

You can change where Anvil looks for customizer profiles by setting the `CUSTOMIZER_SOURCE_BASE_URL`
environment variable before running `rake customizer:update` (or `:import`).

e.g.

```bash
CUSTOMIZER_SOURCE_BASE_URL=https://s3-eu-west-1.amazonaws.com/alces-flight-profiles-eu-west-1/develop/features bin/rake customizer update
``` 

Note that matching is done on (user, name) so existing customizer items will have their S3
URLs replaced with the new one. (We don't yet - 2017-10-23 - use that URL for anything, so
this isn't very important right now. In general we need to think about versioning - both of
content items such as Gridware and customizers, and also in terms of Clusterware version
compatibilities.)

# ANVIL: Offline Install Guide

Anvil is a `metadata` server that records the URL of a series of packages.
It is possible to setup `anvil` to server forge packages over a local
network. By doing so, `flight` can forge install without an external
internet connection.

## Getting Started
### Cloning the git repo

This is a private repo, so the initial install can not be bootstrapped at
this point in time. Instead the repo must be manually clone with your
credentials:
```
git clone https://github.com/alces-software/anvil.git
Cloning into 'anvil'...
Username for 'https://github.com':
Password for 'https://sg@github.com':
```

### Installing ruby, postgres and rails

On a clean centos7 install, RoR w/ Postgres can be installed easily by
running the `scripts/install.sh` script. This will have to be done with
root privileges as it needs to `yum install`.
```
./anvil/scripts/install.sh
```

#### Notes: Installing PostgreSQL

Postgres is not installed using `yum`. The `yum` repo version is Postgres9.2
which is not compatible with the `pg` gem used by rails. The `pg` gem 
contains C native extensions that need to be compiled against the shared
libraries. It is possible add the `postgres9.6` repo to yum, however it
becomes a bit of a hack to get the shared libraries in the correct places.

Instead postgres is installed from source. This way the header files are
immediately ready for `rubygem` to come along latter. The postgres install
can be ran independently with:
```
./anvil/scripts/setup-postgres.sh
```

#### Notes: Installing rvm and RoR

The install script also installs `rvm` ruby, bundler and all the gems.
Rails is automatically setup by this process. However the `rvm` profile
will need to sourced into your environment. It can also be ran independently
with:
```
./anvil/scripts/setup-rvm-rails.sh
source /usr/local/rvm/scripts/rvm
```

If you prefer not install `rvm`, any recent issue version of ruby (2.4 ish)
will do. However `bundler` and the gems will need to be installed with:
```
cd ./anvil
gem install bundler
bundle install
```

##### PS: GPG Key Error
Sometimes the GPG key server hangs/ errors. If this happens, just rerun
`setup-rvm-rails.sh` as PostgreSQL has already been installed. This just
happens occasionally.

## Creating a Database Snapshot

Once rails has been installed, a default snapshot can be created by 
changing to the anvil directory and running the snapshot rake command.

```
# cd ./anvil
# rake packages:snapshot
Which IP/domain are the packages hosted on?
> www.example.com
```

Running this command with no other system configurations sets up the
default server, however it still needs to be told which ip/ domain the
packages will be hosted on. See environment setup for more details

NOTE: The answer should not include the protocol as it will default to 
`http`. However the underlining `ANVIL_BASE_URL` needs to be fully
qualified including the protocol.

### Environment Setup

Running the `snapshot` rake command does not alter your environment setup,
it does however use the following environment variables internally

```
ANVIL_LOCAL_DIR: The base directory for the download. Typically this would
                 be hosted on the rails in built `public` directory or
                 hosted by apache/ enginx. Anvil will store the files in
                 a `packages` sub directory
                 DEFAULT: anvil/public

ANVIL_UPSTREAM:  The upstream anvil database to take the snapshot on. It
                 defaults to the main production database.
                 DEFAULT: https://forge-api.alces-flight.com

ANVIL_BASE_URL:  A fully qualified URL (inc. protocol) to where the
                 packages will be hosted. This will be stored in the db
                 with the package metadata. Thus it does not need to be
                 permanetly set within the environment. There is no default
```

### Drop DB and Running the Snapshot Manually

If the above environment variable are set, then `rake package:snapshot` 
will automatically download and import the database in a single set.

The automatic snapshot will not work if the database already exists as
it can not recover from any errors. Instead the snapshot should be 
preformed step by step using the commands bellow.

It does require the above environment variables to be set manually as well,
refer to `lib/rake/packages.rb` for further details.

```
rake snapshot:download
rake snashot:import
```

Alternatively the database could be dropped with:
```
rake db:drop
```

## Running the Server

You are now ready to start the `anvile` rails server with the command bellow.
This will likely launch in development mode if no further configurations are
made. This means the `public` directory should be statically served without
any futher configurations.

However there is no reason why the packages need to be hosted on this 
machine, the packages can be hosted anywhere as long as the `ANVIL_BASE_URL`
is pointing to its location.

```
rails server -p 80
```

