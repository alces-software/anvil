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

# Importing local packages into the database
It is possible to import packages into the database from a directory. The
directory is searched recursively for all `.zip` files. The packages are
directly added to the database without going through the upload and thus
do not require sign in credentials.

In order for the packages to be added correctly, the base url and package
directory must be set as environment variables:

```
ANVIL_BASE_URL:   A fully qualified URL (inc. protocol) to where the
                  packages will be hosted. This will be stored in the db
                  with the package metadata. Thus it does not need to be
                  permanetly set within the environment.

ANVIL_IMPORT_DIR: The directory the packages are imported from. The import
                  command does not concern itself with the hosting of the
                  packages. It assumes the packages will be found at:
                  http://$ANVIL_BASE_URL/packages/<relative-package-path>

                  Typically packages will be hosted from within the anvil
                  public directory. Thus ANVIL_IMPORT_DIR would normally
                  be set to: /<path-to>/anvil/public/packages

                  However a different static file server could be used
                  (e.g. nginx). In this case the import dir should be set
                  accordingly. It is the responsibility of the user to
                  ensure the package is reachable at the above address.
```

