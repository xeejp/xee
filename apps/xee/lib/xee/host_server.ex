defmodule Xee.HostServer do
  @moduledoc """
  The server to store the experiment ID and its info linked host ID.
  """
  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Stores the experiment ID and its info linked host_id.
  """
  def register(host_id, experiment_id) do
    Agent.update(__MODULE__, fn map ->
      (
      experiments = if Map.has_key?(map, host_id), do: map[host_id], else: MapSet.new
      Map.put(map, host_id, MapSet.put(experiments, experiment_id))
      )
    end)
  end

  @doc """
  Returns all of the experiments created by the host.
  """
  def get(host_id) do
    Agent.get(__MODULE__, fn map ->
      map[host_id]
    end)
  end

  @doc "Checks whether the experiment ID exists or not."
  def has?(host_id, experiment_id) do
    Agent.get(__MODULE__, fn map ->
      Map.has_key?(map, host_id) && MapSet.member?(map[host_id], experiment_id)
    end)
  end

  @doc "Checks whether the given experiments is owned by the same host."
  def has_same_host?(xid1, xid2) do
    Agent.get(__MODULE__, fn map ->
      Enum.any?(map, fn {_host_id, mapset} ->
        MapSet.member?(mapset, xid1) and MapSet.member?(mapset, xid2)
      end)
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

  def drop_all() do
    Agent.update(__MODULE__, fn map -> %{} end)
  end
end
