defmodule XeeWeb.ThemeView do
  use XeeWeb, :view

  def tag_list(conn, tags, themes, depth \\ 0) do
    child = Enum.map_join(tags, fn tag ->
      header = tag |> elem(0)
      body = tag |> elem(1)
      themelist = Enum.filter(themes, fn theme -> Enum.find_value(theme.tags, fn x -> x == header end) end)
                  |> Enum.map_join(fn theme ->
        path = host_path(conn, :experiment, theme_id: theme.id)
        ~s(<li><a href="#{path}" class="btn">#{theme.name}</a></li>) end)
      if body |> length != 0 do
        """
        <li>
          #{header}
          <ul>#{themelist}</ul>
          #{tag_list(conn, body, themes, depth + 1)}
        </li>
        """
      else
        if themelist != "" do
          """
          <li>
          #{header}
          <ul class="none-list">#{themelist}</ul>
          </li>
          """
        else
          ""
        end
      end
    end)

    class = case depth do
      depth when rem(depth, 2) == 0 -> "disc-list"
      _ -> "circle-list"
    end
    ~s(<ul class="indent-list #{class}">#{child}</ul>)
  end

end
