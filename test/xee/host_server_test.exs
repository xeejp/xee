defmodule Xee.HostServerTest do
  use ExUnit.Case
  alias Xee.HostServer, as: HostServer

  setup do
    HostServer.start_link()
    :ok
  end

  test "register and get" do
    assert :ok == HostServer.register(:a, :A, "a")
    assert :ok == HostServer.register(:b, :B, "b")
    assert :ok == HostServer.register(:c, :C1, "c1")
    assert :ok == HostServer.register(:c, :C2, "c2")
    assert %{A: "a"} == HostServer.get(:a)
    assert %{B: "b"} == HostServer.get(:b)
    assert %{C1: "c1", C2: "c2"} == HostServer.get(:c)
  end

  test "has?" do
    HostServer.register(:a, :A, "a")
    HostServer.register(:b, :B, "b")
    HostServer.register(:c, :C1, "c1")
    HostServer.register(:c, :C2, "c2")
    assert HostServer.has?(:a, :A)
    assert HostServer.has?(:b, :B)
    assert HostServer.has?(:c, :C1)
    assert HostServer.has?(:c, :C2)
    refute HostServer.has?(:a, :B)
    refute HostServer.has?(:d, :D)
  end

  test "drop" do
    HostServer.register(:a, :A, "a")
    HostServer.register(:b, :B, "b")
    HostServer.register(:c, :C1, "c1")
    HostServer.register(:c, :C2, "c2")
    assert :ok == HostServer.drop(:a, :A)
    assert :ok == HostServer.drop(:c, :C1)
    refute HostServer.has?(:a, :A)
    assert HostServer.has?(:b, :B)
    refute HostServer.has?(:c, :C1)
    assert HostServer.has?(:c, :C2)
  end
end
