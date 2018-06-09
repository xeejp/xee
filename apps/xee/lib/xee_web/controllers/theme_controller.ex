defmodule XeeWeb.ThemeController do
  use XeeWeb, :controller

  def get_themes do
    Xee.ThemeServer.get_all
    |> Map.to_list
    |> Enum.map(fn {_key, value} -> value end)
    |> Enum.filter(fn theme -> Xee.Theme.granted? theme end)
  end

  def explore(conn, %{"page" => "list"}) do
    themes = get_themes()
    render conn, "list.html", themes: themes
  end

  def explore(conn, %{"page" => "category"}) do
    themes = get_themes()
    tags = Application.get_env(:xee, Xee.ThemeServer)
            |> Keyword.get(:tags, [])
    render conn, "category.html", themes: themes, tags: tags
  end

  def theme(conn, %{"theme_id" => theme_id}) do
    %{description: description, id: id, name: name} = Xee.ThemeServer.get(theme_id)
    unless is_nil(description) do
      javascript = "/theme/#{theme_id}/description.js"
      render conn, "theme.html", id: id, name: name, description: description, javascript: javascript
    else
      render conn, "no_description.html", id: id, name: name
    end
  end

  def description_script(conn, %{"theme_id" => theme_id}) do
    %{description: js} = Xee.ThemeServer.get(theme_id)
    render conn, "description.js", javascript: js
  end
end
