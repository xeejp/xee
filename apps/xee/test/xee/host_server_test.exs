defmodule XeeWeb.HostServerTest do
  use ExUnit.Case
  alias Xee.HostServer, as: HostServer

  setup do
    HostServer.drop_all()
    :ok
  end

  test "register and get" do
    assert :ok == HostServer.register(:a, :A)
    assert :ok == HostServer.register(:b, :B)
    assert :ok == HostServer.register(:c, :C1)
    assert :ok == HostServer.register(:c, :C2)
    assert HostServer.get(:a) |> MapSet.member?(:A)
    assert HostServer.get(:b) |> MapSet.member?(:B)
    assert HostServer.get(:c) |> MapSet.member?(:C1)
    assert HostServer.get(:c) |> MapSet.member?(:C2)
  end

  test "has?" do
    HostServer.register(:a, :A)
    HostServer.register(:b, :B)
    HostServer.register(:c, :C1)
    HostServer.register(:c, :C2)
    assert HostServer.has?(:a, :A)
    assert HostServer.has?(:b, :B)
    assert HostServer.has?(:c, :C1)
    assert HostServer.has?(:c, :C2)
    refute HostServer.has?(:a, :B)
    refute HostServer.has?(:d, :D)
  end

  test "has_same_host?" do
    HostServer.register(:a, :A)
    HostServer.register(:b, :B)
    HostServer.register(:c, :C1)
    HostServer.register(:c, :C2)
    assert HostServer.has_same_host?(:A, :A)
    assert HostServer.has_same_host?(:C1, :C2)
    refute HostServer.has_same_host?(:A, :B)
    refute HostServer.has_same_host?(:B, :C1)
  end

  test "drop" do
    HostServer.register(:a, :A)
    HostServer.register(:b, :B)
    HostServer.register(:c, :C1)
    HostServer.register(:c, :C2)
    assert :ok == HostServer.drop(:a, :A)
    assert :ok == HostServer.drop(:c, :C1)
    refute HostServer.has?(:a, :A)
    assert HostServer.has?(:b, :B)
    refute HostServer.has?(:c, :C1)
    assert HostServer.has?(:c, :C2)
  end
end
