defmodule Sendmail.Mixfile do
  use Mix.Project

  def project do
    [app: :sendmail,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:myapp, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
defp deps do
  [{:phoenix, "~> 1.2.0"},
   {:phoenix_html, "~> 2.6"},
   {:phoenix_ecto, "~> 3.0"},
   {:postgrex, ">= 0.9.1", override: true},
   {:phoenix_live_reload, "~> 1.0", only: :dev},
   {:cowboy, "~> 1.0"},
   {:mailgun, "~> 0.1.2"}]
end
end
