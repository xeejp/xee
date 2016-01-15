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
    {:ok, uid} = Experiment.start_link(experiment, key)
    Agent.update(__MODULE__, fn map -> Map.put(map, key, {uid, info}) end)
  end

  @doc "Sends a host join message to script."
  def join(key) do
    Experiment.join(get(key))
  end

  @doc "Sends a participant join message to script."
  def join(key, participant_id) do
    Experiment.join(get(key), participant_id)
  end

  @doc "Returns the experiments' map."
  def get_all() do
    Agent.get(__MODULE__, fn map -> map end)
  end

  @doc "Returns the experiment."
  def get(key) do
    Agent.get(__MODULE__, fn map -> elem(map[key], 0) end)
  end

  @doc "Returns the info."
  def get_info(key) do
    Agent.get(__MODULE__, fn map -> elem(map[key], 1) end)
  end

  @doc "Removes the experiment."
  def remove(key) do
    Agent.update(__MODULE__, fn map -> Map.delete(map, key) end)
  end
end
