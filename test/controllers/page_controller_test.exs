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
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "経済実験へようこそ！"
  end

  test "GET /theme" do
    conn = get conn(), "/theme"
    assert conn.status == 200
  end

  test "GET /theme with ThemeData" do
    Xee.ThemeServer.register :test,  %{name: "リカード生産比較", playnum: "2235", lastupdate: "2015/1/1", producer: "hoge", contact: "aaa@aaa", manual: ""}
    Xee.ThemeServer.register :test1, %{name: "ダブルオークション実験", playnum: "345", lastupdate: "2015/1/2", producer: "piyo", contact: "bbb@bbb", manual: "#"}
    conn = get conn(), "/theme"
    assert html_response(conn, 200) =~ "<td>リカード生産比較</td>"
  end
end
