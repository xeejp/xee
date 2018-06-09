defmodule XeeWeb.PageControllerTest do
  use XeeWeb.ConnCase
  use ExUnit.Case, async: false

  setup() do
    Xee.ThemeServer.drop_all()
    :ok
  end

  test "GET /" do
    conn = get build_conn(), "/"
    assert html_response(conn, 200) =~ "経済実験へようこそ！"
  end
end
