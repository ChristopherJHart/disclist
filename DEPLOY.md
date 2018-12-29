# Deploying

## Initial setup
```bash
heroku create --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git"
heroku addons:create heroku-postgresql:hobby-dev
heroku config:set POOL_SIZE=18
heroku config:set DISCORD_TOKEN=SUPERSECRET
heroku config:set DISCORD_ID=1234567890
DATABASE_URL=$(heroku config:get DATABASE_URL) mix ecto.migrate
git push heroku master
```