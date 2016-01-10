defmodule Xee.TokenServerTest do
  use ExUnit.Case, async: false
  alias Xee.TokenServer, as: TokenServer

  setup do
    on_exit fn ->
      TokenServer.reset()
    end
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

  test "has_id?" do
    TokenServer.register(:a, "a")
    TokenServer.register(:b, "b")
    TokenServer.register(:c, "c")
    assert TokenServer.has_id?("a")
    assert TokenServer.has_id?("b")
    assert TokenServer.has_id?("c")
  end

  test "generate_id" do
    assert String.length(TokenServer.generate_id()) == 6
    assert String.length(TokenServer.generate_id(10)) == 10
  end
end
