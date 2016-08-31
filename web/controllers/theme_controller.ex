defmodule Xee.ThemeController do
  use Xee.Web, :controller

  def explore(conn, %{"page" => "list"}) do
    themes = Xee.ThemeServer.get_all
              |> Map.to_list
              |> Enum.map(fn {_key, value} -> value end)
              |> Enum.filter(fn theme -> Xee.Theme.granted? theme end)
    render conn, "list.html", themes: themes
  end
end
