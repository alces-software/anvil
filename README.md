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

# Creating a Database Snapshot

The database snapshot can be triggered manually using:
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

## Environment Setup

Running the `snapshot` rake command does not alter your environment setup,
it does however use the following environment variables internally

```
ANVIL_LOCAL_DIR: The base directory for the download. Typically this would
                 be hosted on the rails in built `public` directory or
                 hosted by apache/ enginx. Anvil will store the files in
                 a `packages` sub directory
                 DEFAULT: /path/to/anvil/public

ANVIL_UPSTREAM:  The upstream anvil database to take the snapshot on. It
                 defaults to the main production database.
                 DEFAULT: https://forge-api.alces-flight.com

ANVIL_BASE_URL:  A fully qualified URL (inc. protocol) to where the
                 packages will be hosted. This will be stored in the db
                 with the package metadata. Thus it does not need to be
                 permanetly set within the environment. There is no default
```

## Drop DB and Running the Snapshot Manually

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

You are now ready to start the `anvil` rails server with the command bellow.
This will likely launch in development mode if no further configurations are
made. This means the `public` directory should be statically served without
any futher configurations.

However there is no reason why the packages need to be hosted on this
machine, the packages can be hosted anywhere as long as the
`ANVIL_BASE_URL` was set correctly when the import occurred.
NOTE: Changes to the base url after the fact will be ignored

```
bin/rails server -p 80 -b 0.0.0.0
```

