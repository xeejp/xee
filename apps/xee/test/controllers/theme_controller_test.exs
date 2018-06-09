defmodule Xee.ThemeControllerTest do
  use XeeWeb.ConnCase
  use ExUnit.Case, async: false

  setup() do
    Xee.ThemeServer.drop_all()
    :ok
  end

  test "GET /explore/list" do
    Xee.ThemeServer.experiment "test",
      path: "apps/xee/experiments/test",
      file: "test.exs",
      host: "host.js",
      participant: "participant.js"
    conn = get build_conn(), "/explore/list"
    assert html_response(conn, 200) =~ "<td>test</td>"
  end

  test "get the description page of the theme which has a description" do
    Xee.ThemeServer.experiment "test",
      path: "apps/xee/experiments/test",
      file: "test.exs",
      host: "host.js",
      participant: "participant.js",
      description: "description.js"
    conn = get build_conn(), "/theme/test"
    refute html_response(conn, 200) =~ "ありません"
  end

  test "get the description page of the theme which has no description" do
    Xee.ThemeServer.experiment "test",
      path: "apps/xee/experiments/test",
      file: "test.exs",
      host: "host.js",
      participant: "participant.js"
    conn = get build_conn(), "/theme/test"
    assert html_response(conn, 200) =~ "ありません"
  end

  test "get description.js" do
    Xee.ThemeServer.experiment "test",
      path: "apps/xee/experiments/test",
      file: "test.exs",
      host: "host.js",
      participant: "participant.js",
      description: "description.js"
    conn = get build_conn(), "/theme/test/description.js"
    assert response_content_type(conn, :javascript) =~ "charset=utf-8"
    assert response(conn, 200) =~ "// description" # from experiments/test/description.js
  end
end
