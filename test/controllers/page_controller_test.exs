defmodule Xee.PageControllerTest do
  use Xee.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert conn.status == 200
  end
end
