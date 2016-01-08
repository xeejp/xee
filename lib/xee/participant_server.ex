defmodule Xee.ParticipantServer do
  @moduledoc """
  The server to store participant IDs with experiment IDs.
  """

  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Registers a participant ID with a experiment ID.
  """
  def register(participant_id, experiment_id) do
    Agent.update(__MODULE__, fn map -> Map.put(map, participant_id, experiment_id) end)
  end

  @doc """
  Return the experiment ID of a given participant ID.
  """
  def get(participant_id) do
    Agent.get(__MODULE__, fn map -> map[participant_id] end)
  end

  @doc """
  Remove a given participant ID and experiment ID.
  """
  def drop(participant_id) do
    Agent.update(__MODULE__, fn map -> Map.delete(map, participant_id) end)
  end
end
