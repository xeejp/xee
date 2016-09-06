defmodule Xee.ThemeServerTest do
  use ExUnit.Case
  alias Xee.ThemeServer, as: ThemeServer

  setup do
    ThemeServer.drop_all
    :ok
  end

  test "register and get" do
    assert :ok == ThemeServer.register(:a, :A)
    assert :ok == ThemeServer.register(:b, :B)
    assert :ok == ThemeServer.register(:c, :C)
    assert :A == ThemeServer.get(:a)
    assert :B == ThemeServer.get(:b)
    assert :C == ThemeServer.get(:c)
  end

  test "register and get_all" do
    assert :ok == ThemeServer.register(:a, :A)
    assert :ok == ThemeServer.register(:b, :B)
    assert :ok == ThemeServer.register(:c, :C)
    assert %{a: :A, b: :B, c: :C} == ThemeServer.get_all()
  end

  test "register and delete" do
    assert :ok == ThemeServer.register(:a, :A)
    assert :ok == ThemeServer.register(:b, :B)
    assert :ok == ThemeServer.register(:c, :C)
    assert :ok == ThemeServer.delete(:b)
    assert %{a: :A, c: :C} == ThemeServer.get_all()
  end

  test "register and drop_all" do
    assert :ok == ThemeServer.register(:a, :A)
    assert :ok == ThemeServer.register(:b, :B)
    assert :ok == ThemeServer.register(:c, :C)
    assert :ok == ThemeServer.drop_all()
    assert %{} == ThemeServer.get_all()
  end
end
