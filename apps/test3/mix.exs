defmodule Test3.Mixfile do
  use Mix.Project

  def project do
    [
     app: :test3,
     version: "0.1.0",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib",]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:xeethemescript, "~> 0.3.0"},
      {:phoenix, "~> 1.3.2"},
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
      {:tzdata, "~> 0.5.16"}
    ]
  end
end
