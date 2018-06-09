defmodule XeeWeb.PageController do
  use XeeWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def about(conn, _params) do
    themes = Xee.ThemeServer.get_all
              |> Map.to_list
              |> Enum.map(fn {_key, value} -> value end)
              |> Enum.filter(fn theme -> Xee.Theme.granted? theme end)
    members = [
      %{position: "<strong>Principal Investigator</strong> / Ph.D. in Economics", name: "Ryohei Hayashi (林 良平)", url: "https://github.com/RyoheiHayashi"},
      %{position: "<strong>System Designer</strong> / Xee System Programmer / Experiments Programmer", name: "Ryo Hashiguchi (橋口 遼)", url: "https://github.com/ryo33"},
      %{position: "<strong>Xee System Programmer</strong> / Experiments Programmer", name: "Iori Ikeda (池田 伊織)", url: "https://github.com/NotFounds"},
      %{position: "<strong>Xee System Programmer</strong>", name: "Akira Fukunaga (福永 彬)", url: "https://github.com/kagemiku"},
      %{position: "<strong>Experiments Programmer</strong>", name: "Hiroki Kataoka (片岡 大樹)", url: "https://github.com/kyataoka"},
      %{position: "<strong>Experiments Programmer</strong>", name: "Koichiro Hatakeyama (畑山 紘一朗)", url: "https://github.com/koo3701"},
      %{position: "<strong>Experiments Programmer</strong>", name: "Syoya Matsumoto (松元 翔矢)", url: "https://github.com/M42M0"},
      %{position: "<strong>Experiments Programmer</strong>", name: "Taiki Mizo (溝 大貴)", url: "https://github.com/kazuwo"},
      %{position: "<strong>Experiments Programmer</strong> / Xee System Programmer", name: "Wataru Yunoue (湯之上 航)", url: "https://github.com/hayarasu308"},
      %{position: "<strong>Experiments Programmer</strong>", name: "Kenta Konagayoshi (小永吉　健太)", url: "https://github.com/konaken"},
      %{position: "<strong>System Planner</strong>", name: "Kensuke Sumizawa (住澤 研介)", url: "https://github.com/ShiroQ"},
      %{position: "<strong>System Planner</strong> / Experiments Programmer", name: "Tatsuya Takenouchi (竹ノ内 達哉)", url: "https://github.com/InsideOfBamboo"},
    ]
    render conn, "about.html", themes: themes , members: members
  end
end
