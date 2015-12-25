defmodule Xee.TokenServerTest do
  use ExUnit.Case
  alias Xee.TokenServer, as: TokenServer

  setup do
    TokenServer.start_link()
    :ok
  end

  test "register and get" do
    assert :ok == TokenServer.register(:a, "a")
    assert :ok == TokenServer.register(:b, "b")
    assert :ok == TokenServer.register(:c, "c")
    assert "a" == TokenServer.get(:a)
    assert "b" == TokenServer.get(:b)
    assert "c" == TokenServer.get(:c)
    assert nil == TokenServer.get(:d)
  end

  test "has?" do
    TokenServer.register(:a, "a")
    TokenServer.register(:b, "b")
    TokenServer.register(:c, "c")
    assert TokenServer.has?(:a)
    assert TokenServer.has?(:b)
    assert TokenServer.has?(:c)
  end

  test "drop" do
    TokenServer.register(:a, "a")
    TokenServer.register(:b, "b")
    TokenServer.register(:c, "c")
    assert :ok == TokenServer.drop(:b)
    assert TokenServer.has?(:a)
    refute TokenServer.has?(:b)
    assert TokenServer.has?(:c)
  end

  test "change" do
    TokenServer.register(:a, "a")
    TokenServer.register(:b, "b")
    TokenServer.register(:c, "c")
    assert :ok == TokenServer.change(:b, :d)
    assert :error == TokenServer.change(:e, :f)
    assert TokenServer.has?(:a)
    refute TokenServer.has?(:b)
    assert TokenServer.has?(:c)
    assert TokenServer.has?(:d)
  end
end
