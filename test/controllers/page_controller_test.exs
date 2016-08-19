defmodule Xee.PageControllerTest do
  use Xee.ConnCase
  use ExUnit.Case, async: false

  setup() do
    Xee.ThemeServer.drop_all()
    :ok
  end

  test "GET /" do
    conn = get build_conn(), "/"
    assert html_response(conn, 200) =~ "経済実験へようこそ！"
  end

  test "GET /theme" do
    conn = get build_conn(), "/theme"
    assert conn.status == 200
  end

  test "GET /theme with ThemeData" do
    Xee.ThemeServer.load("test/assets/example_experiments.exs")
    conn = get build_conn(), "/theme"
    assert html_response(conn, 200) =~ "<td>example1</td>"
  end
end
