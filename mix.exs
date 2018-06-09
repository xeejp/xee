defmodule XeeJP.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.0.1",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  defp deps do
    [{:xeethemescript, "~> 0.3.0"}]
  end
end
