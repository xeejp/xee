defmodule Xee.ExperimentChannelTest do
  use ExUnit.Case, async: false
  use Xee.ChannelCase
  use Xee.ExperimentTestHelper

  alias Xee.ExperimentServer
  alias Xee.Experiment

  setup do
    ExperimentServer.create("x1", test_experiment, "")
    prepare_servers
    host_socket = join_channel("x1")
    participant_socket = join_channel("x1", "p1")
    on_exit fn ->
      Xee.ExperimentServer.stop()
      stop([host_socket, participant_socket])
    end
    {:ok, host_socket: host_socket, participant_socket: participant_socket}
  end

  test "push from client", %{host_socket: host_socket, participant_socket: participant_socket} do
    name = ExperimentServer.get("x1")
    push host_socket, "client", 1
    :timer.sleep(15)
    assert %{"data" => %{"host" => ["1"], "participant" => %{"p1" => []}}, "host" => ["1"], "participant" => %{"p1" => []}} == Experiment.fetch(name)
    assert_broadcast "update", %{body: ["1"]}
    push participant_socket, "client", 2
    :timer.sleep(15)
    assert %{"data" => %{"host" => ["1"], "participant" => %{"p1" => ["2"]}}, "host" => ["1"], "participant" => %{"p1" => ["2"]}} == Experiment.fetch(name)
    assert_broadcast "update", %{body: ["2"]}
  end

  test "broadcasts are pushed to the client", %{host_socket: host_socket, participant_socket: participant_socket} do
    broadcast_from! host_socket, "update", %{"some" => "data"}
    assert_push "update", %{"some" => "data"}
    broadcast_from! participant_socket, "update", %{"some" => "data"}
    assert_push "update", %{"some" => "data"}
  end
end
