defmodule Xee.ParticipantServerTest do
  use ExUnit.Case, async: true
  alias Xee.ParticipantServer, as: ParticipantServer

  setup do
    ParticipantServer.start_link()
    :ok
  end

  test "register and get" do
    assert :ok == ParticipantServer.register(:a, :A)
    assert :ok == ParticipantServer.register(:b, :B)
    assert :ok == ParticipantServer.register(:c, :C)
    assert :A  == ParticipantServer.get(:a)
    assert :B  == ParticipantServer.get(:b)
    assert :C  == ParticipantServer.get(:c)
  end

  test "register and get, reregistration" do
    assert :ok == ParticipantServer.register(:a, :A)
    assert :ok == ParticipantServer.register(:b, :B)
    assert :ok == ParticipantServer.register(:c, :C)
    assert :A  == ParticipantServer.get(:a)
    assert :B  == ParticipantServer.get(:b)
    assert :C  == ParticipantServer.get(:c)
    assert :ok == ParticipantServer.register(:a, :aA)
    assert :ok == ParticipantServer.register(:b, :bB)
    assert :ok == ParticipantServer.register(:c, :cC)
    assert :aA == ParticipantServer.get(:a)
    assert :bB == ParticipantServer.get(:b)
    assert :cC == ParticipantServer.get(:c)
  end

  test "register and drop" do
    assert :ok == ParticipantServer.register(:a, :A)
    assert :ok == ParticipantServer.register(:b, :B)
    assert :ok == ParticipantServer.register(:c, :C)
    assert :ok == ParticipantServer.drop(:a)
    assert :ok == ParticipantServer.drop(:b)
    assert :ok == ParticipantServer.drop(:c)
  end

  test "register and get, drop" do
    assert :ok == ParticipantServer.register(:a, :A)
    assert :ok == ParticipantServer.register(:b, :B)
    assert :ok == ParticipantServer.register(:c, :C)
    assert :A  == ParticipantServer.get(:a)
    assert :B  == ParticipantServer.get(:b)
    assert :C  == ParticipantServer.get(:c)
    assert :ok == ParticipantServer.drop(:a)
    assert :ok == ParticipantServer.drop(:b)
    assert :ok == ParticipantServer.drop(:c)
    assert nil == ParticipantServer.get(:a)
    assert nil == ParticipantServer.get(:b)
    assert nil == ParticipantServer.get(:c)
  end
end
