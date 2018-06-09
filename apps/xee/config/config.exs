# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :xee, ecto_repos: [Xee.Repo]

# Configures the endpoint
config :xee, XeeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YMHjvC+X66HvbtH0da1w6v5rJh+wvPjUW7Iqaq0c7aQgxk1uOp5o0DLz+wW4BD5d",
  render_errors: [default_format: "html"],
  pubsub: [name: Xee.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Imports a config file by environment
import_config "#{Mix.env}.exs"
