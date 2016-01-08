defmodule Xee.ParticipantServerTest do
  use ExUnit.Case, async: true
  alias Xee.ParticipantServer

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

  test "reregistration" do
    ParticipantServer.register(:a, :A)
    ParticipantServer.register(:b, :B)

    assert :A  == ParticipantServer.get(:a)
    assert :ok == ParticipantServer.register(:a, :aA)
    assert :aA == ParticipantServer.get(:a)

    assert :B  == ParticipantServer.get(:b)
    assert :ok == ParticipantServer.register(:b, :bB)
    assert :bB == ParticipantServer.get(:b)
  end

  test "drop" do
    ParticipantServer.register(:a, :A)
    ParticipantServer.register(:b, :B)

    assert :A  == ParticipantServer.get(:a)
    assert :ok == ParticipantServer.drop(:a)
    assert nil == ParticipantServer.get(:a)

    assert :B  == ParticipantServer.get(:b)
    assert :ok == ParticipantServer.drop(:b)
    assert nil == ParticipantServer.get(:b)
  end
end
