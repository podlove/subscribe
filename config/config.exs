# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :subscribe,
  ecto_repos: [Subscribe.Repo]

# Configures the endpoint
config :subscribe, SubscribeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "aJqcLpOG5VbKvaZJ3PG6vwNZwQQbfbxpqwgX59lNluYmnan371086jLr4d76TGnM",
  render_errors: [view: SubscribeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Subscribe.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :subscribe,
  gzip_static: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
