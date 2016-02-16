defmodule Xee.HostServer do
  @moduledoc """
  The server to store experiment ID and its info linked host ID.
  """
  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Stores experiment ID and its info linked host_id.
  """
  def register(host_id, experiment_id) do
    Agent.update(__MODULE__, fn map ->
      (
      experiments = if Map.has_key?(map, host_id), do: map[host_id], else: MapSet.new
      Map.put(map, host_id, MapSet.put(experiments, experiment_id))
      ) end)
  end

  @doc """
  Returns all of experiments created by the host.
  """
  def get(host_id) do
    Agent.get(__MODULE__, fn map ->
      map[host_id]
    end)
  end

  @doc "Checks whether experiment ID exists or not."
  def has?(host_id, experiment_id) do
    Agent.get(__MODULE__, fn map ->
      Map.has_key?(map, host_id) && MapSet.member?(map[host_id], experiment_id)
    end)
  end

  @doc "Removes the experiment_ID."
  def drop(host_id, experiment_id) do
    Agent.update(__MODULE__, fn map ->
      if Map.has_key?(map, host_id) do
        Map.put(map, host_id, MapSet.delete(map[host_id], experiment_id))
      else
        map
      end
    end)
  end
end
