defmodule XeeWeb.ExperimentChannelTest do
  use ExUnit.Case, async: false
  use XeeWeb.ChannelCase
  use XeeWeb.ExperimentTestHelper

  alias Xee.ExperimentServer
  alias Xee.Experiment

  setup do
    prepare_servers
    # test1
    ExperimentServer.create("x1", test_experiment, "")
    host_socket = join_channel("x1")
    participant_socket = join_channel("x1", "p1")
    # test2
    ExperimentServer.create("x2", test2_experiment, "")
    host_socket2 = join_channel("x2")
    participant_socket2 = join_channel("x2", "p1")

    on_exit fn ->
      stop([host_socket, participant_socket])
      stop([host_socket2, participant_socket2])
    end
    {:ok, host_socket: host_socket, participant_socket: participant_socket,
     host_socket2: host_socket2, participant_socket2: participant_socket2}
  end

  test "push from client", %{host_socket: host_socket, participant_socket: participant_socket} do
    name = ExperimentServer.get("x1")
    push host_socket, "client", %{"body" => 1}
    :timer.sleep(15)
    assert %{"data" => %{"host" => [1], "participant" => %{"p1" => []}}, "host" => [1], "participant" => %{"p1" => []}} == Experiment.fetch(name)
    assert_broadcast "update", %{body: [1]}
    push participant_socket, "client", %{"body" => 2}
    :timer.sleep(15)
    assert %{"data" => %{"host" => [1], "participant" => %{"p1" => [2]}}, "host" => [1], "participant" => %{"p1" => [2]}} == Experiment.fetch(name)
    assert_broadcast "update", %{body: [2]}
  end

  test "fetch", %{host_socket: host_socket, participant_socket: participant_socket} do
    push host_socket, "fetch", %{}
    assert_broadcast "update", %{body: []}
    push participant_socket, "fetch", %{}
    assert_broadcast "update", %{body: []}
  end

  test "broadcasts are pushed to the client", %{host_socket: host_socket, participant_socket: participant_socket} do
    broadcast_from! host_socket, "update", %{"some" => "data"}
    assert_push "update", %{"some" => "data"}
    broadcast_from! participant_socket, "update", %{"some" => "data"}
    assert_push "update", %{"some" => "data"}
  end

  test "push from client 2", %{host_socket2: host_socket, participant_socket2: participant_socket} do
    name = ExperimentServer.get("x2")
    push host_socket, "client", %{"body" => 1}
    :timer.sleep(30)
    assert %{"data" => %{"host" => [1], "participant" => %{"p1" => []}}} == Experiment.fetch(name)
    assert_broadcast "message", %{body: [1]}
    push participant_socket, "client", %{"body" => 2}
    :timer.sleep(30)
    assert %{"data" => %{"host" => [1], "participant" => %{"p1" => [2]}}} == Experiment.fetch(name)
    assert_broadcast "message", %{body: [2]}
  end

  test "fetch 2", %{host_socket2: host_socket, participant_socket2: participant_socket} do
    push host_socket, "fetch", %{}
    assert_broadcast "update", %{body: []}
    push participant_socket, "fetch", %{}
    assert_broadcast "update", %{body: []}
  end

  test "broadcasts are pushed to the client 2", %{host_socket2: host_socket, participant_socket2: participant_socket} do
    broadcast_from! host_socket, "update", %{"some" => "data"}
    assert_push "update", %{"some" => "data"}
    broadcast_from! participant_socket, "update", %{"some" => "data"}
    assert_push "update", %{"some" => "data"}
  end

  test "redirect", %{host_socket2: host_socket} do
    push host_socket, "client", %{"body" => %{"action" => "redirect", "id" => "p2", "xid" => "a"}}
    assert_broadcast "redirect", %{body: "a"}
  end
end
