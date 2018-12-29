# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :nostrum,
  # The token of your bot as a string
  token: System.get_env("DISCORD_TOKEN"),
  num_shards: :auto

config :disclist, ecto_repos: [Disclist.Repo]

config :disclist, Disclist.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true

config :disclist, Disclist.Endpoint, port: System.get_env("PORT")

config :logger, 
  handle_otp_reports: true,
  handle_sasl_reports: true