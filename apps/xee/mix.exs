defmodule Xee.Mixfile do
  use Mix.Project

  def project do
    [app: :xee,
     version: "0.0.1",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Xee, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext, :timex,
                    :phoenix_ecto, :postgrex, :comeonin, :fwatch]]
  end

  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  def deps do
    [{:phoenix, "~> 1.3.2"},
     {:xeethemescript, "~> 0.3.0"},
     {:phoenix_pubsub, "~> 1.0.2"},
     {:phoenix_ecto, "~> 3.3.0"},
     {:postgrex, ">= 0.13.5"},
     {:phoenix_html, "~> 2.11.2"},
     {:phoenix_live_reload, "~> 1.1.5", only: :dev},
     {:gettext, "~> 0.15.0"},
     {:cowboy, "~> 1.0"},
     {:uuid, "~> 1.1.8" },
     {:poison, "~> 3.1.0"},
     {:comeonin, "~> 4.1.1"},
     {:fwatch, "~> 0.5.0"},
     {:timex, "~> 3.3.0"},
     {:tzdata, "~> 0.5.16"}]
  end
end
