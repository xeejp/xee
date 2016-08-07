defmodule Xee.PageControllerTest do
  use Xee.ConnCase
  use ExUnit.Case, async: false

  setup() do
    Xee.ThemeServer.start_link
    on_exit fn ->
      case Process.whereis(Xee.ThemeServer) do
        pid when is_pid(pid) -> Process.exit(pid, :kill)
        _ -> nil
      end
    end
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
