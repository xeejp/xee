defmodule Xee.ThemeControllerTest do
  use Xee.ConnCase
  use ExUnit.Case, async: false

  setup() do
    Xee.ThemeServer.drop_all()
    :ok
  end

  test "GET /explore/list" do
    Xee.ThemeServer.load("test/assets/example_experiments.exs")
    conn = get build_conn(), "/explore/list"
    assert html_response(conn, 200) =~ "<td>example1</td>"
  end
end
