# Deployment to Dokku

For the first time:

 - Create a Dokku app and linked Postgres service
 - Override the autodetection of buildpacks, which gets confused by the presence of a 
 `Dockerfile`:
 `dokku config:set <app> BUILDPACK_URL=https://github.com/heroku/heroku-buildpack-ruby.git`
 - Run `dokku run <app> rake db:setup` to initialise the database
   - Todo: for now the `alces` user isn't created properly, so you'll need to fix one up
   manually via `dokku run <app> rails console`. Be sure to call `confirm` on the `User`.
 - Set a secret for creating JSON Web Tokens:
     `dokku config:set <app> JSON_WEB_TOKEN_SECRET=<somesecret>`
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
