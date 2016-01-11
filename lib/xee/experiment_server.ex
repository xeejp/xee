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
  def create(key, experiment) do
    {:ok, uid} = Experiment.start_link(experiment, key)
    Agent.update(__MODULE__, fn map -> Map.put(map, key, uid) end)
  end

  @doc "Sends a join message to script."
  def join(key, participant_id) do
    Agent.get(__MODULE__, fn map -> Experiment.join(map[key], participant_id) end)
  end

  @doc "Returns the experiments' map."
  def get_all() do
    Agent.get(__MODULE__, fn map -> map end)
  end

  @doc "Returns the experiment."
  def get(key) do
    Agent.get(__MODULE__, fn map -> map[key] end)
  end

  @doc "Removes the experiment."
  def remove(key) do
    Agent.update(__MODULE__, fn map -> Map.delete(map, key) end)
  end
end