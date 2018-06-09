defmodule XeeWeb.ExperimentTest do
  use ExUnit.Case, async: false
  use XeeWeb.ChannelCase
  use XeeWeb.ExperimentTestHelper
  alias Xee.ExperimentServer
  alias Xee.Experiment

  setup do
    prepare_servers

    # test
    ExperimentServer.create("a", test_experiment, "")
    pid = ExperimentServer.get("a")
    host_socket = join_channel("a")
    participant_socket1 = join_channel("a", "p1")
    participant_socket2 = join_channel("a", "p2")

    # test2
    ExperimentServer.create("b", test2_experiment, "")
    pid2 = ExperimentServer.get("b")
    host_socket2 = join_channel("b")
    participant_socket2_1 = join_channel("b", "p1")
    participant_socket2_2 = join_channel("b", "p2")

    on_exit fn ->
      stop([host_socket, participant_socket1, participant_socket2])
      stop([host_socket2, participant_socket2_1, participant_socket2_2])
    end
    {:ok, pid: pid, pid2: pid2}
  end

  test "remove", %{pid: pid} do
    assert Process.alive?(pid)
    Experiment.stop(pid)
    refute Process.alive?(pid)
  end

  test "fetch", %{pid: pid} do
    assert %{"data" => %{"host" => [], "participant" => %{"p1" => [], "p2" => []}},
      "host" => [], "participant" => %{"p1" => [], "p2" => []}} == Experiment.fetch(pid)
  end

  test "fetch 2", %{pid2: pid} do
    assert %{"data" => %{"host" => [], "participant" => %{"p1" => [], "p2" => []}}} == Experiment.fetch(pid)
  end

  test "host client", %{pid: pid} do
    Experiment.client(pid, "message 1")
    assert %{"data" => %{"host" => ["message 1"], "participant" => %{"p1" => [], "p2" => []}},
      "host" => ["message 1"], "participant" => %{"p1" => [], "p2" => []}} == Experiment.fetch(pid)
    Experiment.client(pid, "message 2")
    assert %{"data" => %{"host" => ["message 1", "message 2"], "participant" => %{"p1" => [], "p2" => []}},
      "host" => ["message 1", "message 2"], "participant" => %{"p1" => [], "p2" => []}} == Experiment.fetch(pid)
  end

  test "host client 2", %{pid2: pid} do
    Experiment.client(pid, "message 1")
    assert %{"data" => %{"host" => ["message 1"], "participant" => %{"p1" => [], "p2" => []}}} == Experiment.fetch(pid)
    Experiment.client(pid, "message 2")
    assert %{"data" => %{"host" => ["message 1", "message 2"], "participant" => %{"p1" => [], "p2" => []}}} == Experiment.fetch(pid)
  end

  test "participant client", %{pid: pid} do
    Experiment.client(pid, "message 1", "p1")
    assert %{"data" => %{"host" => [], "participant" => %{"p1" => ["message 1"], "p2" => []}},
      "host" => [], "participant" => %{"p1" => ["message 1"], "p2" => []}} == Experiment.fetch(pid)
    Experiment.client(pid, "message 2", "p1")
    assert %{"data" => %{"host" => [], "participant" => %{"p1" => ["message 1", "message 2"], "p2" => []}},
      "host" => [], "participant" => %{"p1" => ["message 1", "message 2"], "p2" => []}} == Experiment.fetch(pid)
    Experiment.client(pid, "message 3", "p2")
    assert %{"data" => %{"host" => [], "participant" => %{"p1" => ["message 1", "message 2"], "p2" => ["message 3"]}},
      "host" => [], "participant" => %{"p1" => ["message 1", "message 2"], "p2" => ["message 3"]}} == Experiment.fetch(pid)
    Experiment.client(pid, "message 4", "p2")
    assert %{"data" => %{"host" => [], "participant" => %{"p1" => ["message 1", "message 2"], "p2" => ["message 3", "message 4"]}},
      "host" => [], "participant" => %{"p1" => ["message 1", "message 2"], "p2" => ["message 3", "message 4"]}} == Experiment.fetch(pid)
    Experiment.client(pid, "message 5", "p1")
    assert %{"data" => %{"host" => [], "participant" => %{"p1" => ["message 1", "message 2", "message 5"], "p2" => ["message 3", "message 4"]}},
      "host" => [], "participant" => %{"p1" => ["message 1", "message 2", "message 5"], "p2" => ["message 3", "message 4"]}} == Experiment.fetch(pid)
  end

  test "participant client 2", %{pid2: pid} do
    Experiment.client(pid, "message 1", "p1")
    assert %{"data" => %{"host" => [], "participant" => %{"p1" => ["message 1"], "p2" => []}}} == Experiment.fetch(pid)
    Experiment.client(pid, "message 2", "p1")
    assert %{"data" => %{"host" => [], "participant" => %{"p1" => ["message 1", "message 2"], "p2" => []}}} == Experiment.fetch(pid)
    Experiment.client(pid, "message 3", "p2")
    assert %{"data" => %{"host" => [], "participant" => %{"p1" => ["message 1", "message 2"], "p2" => ["message 3"]}}} == Experiment.fetch(pid)
    Experiment.client(pid, "message 4", "p2")
    assert %{"data" => %{"host" => [], "participant" => %{"p1" => ["message 1", "message 2"], "p2" => ["message 3", "message 4"]}}} == Experiment.fetch(pid)
    Experiment.client(pid, "message 5", "p1")
    assert %{"data" => %{"host" => [], "participant" => %{"p1" => ["message 1", "message 2", "message 5"], "p2" => ["message 3", "message 4"]}}} == Experiment.fetch(pid)
  end

  test "client", %{pid: pid} do
    Experiment.client(pid, "message 1", "p1")
    assert %{"data" => %{"host" => [], "participant" => %{"p1" => ["message 1"], "p2" => []}},
      "host" => [], "participant" => %{"p1" => ["message 1"], "p2" => []}} == Experiment.fetch(pid)
    Experiment.client(pid, "message 2")
    assert %{"data" => %{"host" => ["message 2"], "participant" => %{"p1" => ["message 1"], "p2" => []}},
      "host" => ["message 2"], "participant" => %{"p1" => ["message 1"], "p2" => []}} == Experiment.fetch(pid)
    Experiment.client(pid, "message 3", "p2")
    assert %{"data" => %{"host" => ["message 2"], "participant" => %{"p1" => ["message 1"], "p2" => ["message 3"]}},
      "host" => ["message 2"], "participant" => %{"p1" => ["message 1"], "p2" => ["message 3"]}} == Experiment.fetch(pid)
    Experiment.client(pid, "message 4")
    assert %{"data" => %{"host" => ["message 2", "message 4"], "participant" => %{"p1" => ["message 1"], "p2" => ["message 3"]}},
      "host" => ["message 2", "message 4"], "participant" => %{"p1" => ["message 1"], "p2" => ["message 3"]}} == Experiment.fetch(pid)
  end

  test "client 2", %{pid2: pid} do
    Experiment.client(pid, "message 1", "p1")
    assert %{"data" => %{"host" => [], "participant" => %{"p1" => ["message 1"], "p2" => []}}} == Experiment.fetch(pid)
    Experiment.client(pid, "message 2")
    assert %{"data" => %{"host" => ["message 2"], "participant" => %{"p1" => ["message 1"], "p2" => []}}} == Experiment.fetch(pid)
    Experiment.client(pid, "message 3", "p2")
    assert %{"data" => %{"host" => ["message 2"], "participant" => %{"p1" => ["message 1"], "p2" => ["message 3"]}}} == Experiment.fetch(pid)
    Experiment.client(pid, "message 4")
    assert %{"data" => %{"host" => ["message 2", "message 4"], "participant" => %{"p1" => ["message 1"], "p2" => ["message 3"]}}} == Experiment.fetch(pid)
  end

  test "attach_meta", %{pid2: pid} do
    Experiment.attach_meta(pid, "host_id", "token")
    assert_broadcast "message", %{body: %{host_id: "host_id", token: "token"}}
  end
end
