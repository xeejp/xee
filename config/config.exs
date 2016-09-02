# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

defmodule Xee.ThemeConfig do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      {:ok, pid} = Agent.start_link(fn -> %{module_themes: [], file_themes: []} end)
      var!(theme_config, Xee.ThemeConfig) = pid
    end
  end

  defmacro register_themes do
    quote do
      %{
        module_themes: module_themes,
        file_themes: file_themes
      } = Agent.get(var!(theme_config, Xee.ThemeConfig), fn map -> map end)
      config :xee, Xee.ThemeServer,
        file_themes: file_themes,
        module_themes: module_themes
    end
  end

  defmacro theme(name, params) do
    name = Macro.expand(name, __CALLER__)
    if is_atom(name) do
      quote do
        Agent.update(var!(theme_config, Xee.ThemeConfig), fn map ->
          Map.update!(map, :module_themes, fn themes -> [{unquote(name), unquote(params)} | themes] end)
        end)
      end
    else
      quote do
        Agent.update(var!(theme_config, Xee.ThemeConfig), fn map ->
          Map.update!(map, :file_themes, fn themes -> [{unquote(name), unquote(params)} | themes] end)
        end)
      end
    end
  end
end

config :xee, ecto_repos: [Xee.Repo]

# Configures the endpoint
config :xee, Xee.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YMHjvC+X66HvbtH0da1w6v5rJh+wvPjUW7Iqaq0c7aQgxk1uOp5o0DLz+wW4BD5d",
  render_errors: [default_format: "html"],
  pubsub: [name: Xee.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures experiments definition files
config :xee, Xee.ThemeServer,
  files: ["config/experiments.exs"]


config :xee, Xee.ThemeServer,
  module_themes: [],
  file_themes: []
import_config "themes.exs"

# Imports a config file by environment
import_config "#{Mix.env}.exs"
