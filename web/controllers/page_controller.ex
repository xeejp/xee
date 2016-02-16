defmodule Xee.PageController do
  use Xee.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def theme(conn, _params) do
    themes = Xee.ThemeServer.get_all
              |> Map.to_list
              |> Enum.map(fn {_key, value} -> value end)
              |> Enum.filter(fn theme -> Xee.Theme.granted? theme end)
    render conn, "theme.html", themes: themes
  end
end
