defmodule Xee.ExperimentTest do
  use ExUnit.Case, async: false
  use Xee.ExperimentTestHelper
  alias Xee.ExperimentServer
  alias Xee.Experiment

  setup do
    ExperimentServer.create("a", test_experiment, "")
    pid = ExperimentServer.get("a")
    prepare_servers
    host_socket = join_channel("a")
    participant_socket1 = join_channel("a", "p1")
    participant_socket2 = join_channel("a", "p2")
    on_exit fn ->
      ExperimentServer.stop()
      stop([host_socket, participant_socket1, participant_socket2])
    end
    {:ok, pid: pid}
  end

  test "fetch", %{pid: pid} do
    assert %{"data" => %{"host" => [], "participant" => %{"p1" => [], "p2" => []}},
      "host" => [], "participant" => %{"p1" => [], "p2" => []}} == Experiment.fetch(pid)
  end

  test "host client", %{pid: pid} do
    Experiment.client(pid, "message 1")
    assert %{"data" => %{"host" => ["message 1"], "participant" => %{"p1" => [], "p2" => []}},
      "host" => ["message 1"], "participant" => %{"p1" => [], "p2" => []}} == Experiment.fetch(pid)
    Experiment.client(pid, "message 2")
    assert %{"data" => %{"host" => ["message 1", "message 2"], "participant" => %{"p1" => [], "p2" => []}},
      "host" => ["message 1", "message 2"], "participant" => %{"p1" => [], "p2" => []}} == Experiment.fetch(pid)
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
end
