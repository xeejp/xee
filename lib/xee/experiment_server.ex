defmodule Xee.ExperimentServer do
  alias Xee.Experiment

  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc "Stops the server."
  def stop() do
    :ok = Agent.stop(__MODULE__)
  end

  @doc "Checks whether the key is used."
  def has?(key) do
    Agent.get(__MODULE__, fn map -> Map.has_key?(map, key) end)
  end

  @doc "Creates and Register a experiment."
  def create(key, experiment, info) do
    Agent.update(__MODULE__, fn map -> Map.put(map, key, {nil, nil, info}) end)
    {:ok, svpid} = Experiment.start_link(experiment, key)
    Agent.update(__MODULE__, fn map ->
      {_, pid, info} = map[key]
      Map.put(map, key, {svpid, pid, info})
    end)
  end

  @doc "Returns the experiment data."
  def fetch(key) do
    Experiment.fetch(get_pid(key))
  end

  @doc "Handle received data from hosts."
  def client(key, data) do
    Experiment.client(get_pid(key), data)
  end

  @doc "Handle received data from participants."
  def client(key, data, id) do
    Experiment.client(get_pid(key), data, id)
  end

  @doc "Sends a join message to script."
  def join(key, participant_id) do
    Experiment.join(get_pid(key), participant_id)
  end

  @doc "Returns the experiments' map."
  def get_all() do
    Agent.get(__MODULE__, fn map -> map end)
  end

  def set_pid(xid, pid) do
    Agent.update(__MODULE__, fn map ->
      {svpid, _, info} = map[xid]
      %{map | xid => {svpid, pid, info}}
    end)
  end

  def get_pid(xid) do
    Agent.get(__MODULE__, fn map -> elem(map[xid], 1) end)
  end

  @doc "Returns the info."
  def get_info(key) do
    Agent.get(__MODULE__, fn map -> elem(map[key], 2) end)
  end

  @doc "Removes the experiment."
  def remove(key) do
    Agent.update(__MODULE__, fn map -> Map.delete(map, key) end)
  end
end
