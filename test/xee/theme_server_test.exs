defmodule Xee.ThemeServerTest do
  use Xee.ConnCase
  alias Xee.ThemeServer, as: ThemeServer

  setup do
    ThemeServer.start_link()
    :ok
  end

  test "register and get" do
    assert :ok = ThemeServer.register(:a, :A)
    assert :ok = ThemeServer.register(:b, :B)
    assert :ok = ThemeServer.register(:c, :C)
    assert :A = ThemeServer.get(:a)
    assert :B = ThemeServer.get(:b)
    assert :C = ThemeServer.get(:c)
  end

  test "register and get_all" do
    assert :ok = ThemeServer.register(:a, :A)
    assert :ok = ThemeServer.register(:b, :B)
    assert :ok = ThemeServer.register(:c, :C)
    assert %{a: :A, b: :B, c: :C} = ThemeServer.get_all()
  end
end
