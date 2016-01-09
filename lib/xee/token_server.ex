defmodule Xee.TokenServer do
  @moduledoc """
  The server to store tokens to access experiment easily.
  """
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc "Checks whether the token is used."
  def has?(token) do
    GenServer.call(__MODULE__, {:has, token})
  end

  @doc """
  Returns the experiment id.

  This returns nil when token doesn't exist.
  """
  def get(token) do
    GenServer.call(__MODULE__, {:get, token})
  end

  @doc "Registers a token and an experiment ID."
  def register(token, experiment_id) do
    GenServer.cast(__MODULE__, {:register, token, experiment_id})
  end

  @doc "Drops the token."
  def drop(token) do
    GenServer.cast(__MODULE__, {:drop, token})
  end

  @doc """
  Changes the token.

  This returns :ok when token was changed successfully, :error otherwise.
  """
  def change(token, new_token) do
    GenServer.call(__MODULE__, {:change, token, new_token})
  end

  # Callbacks

  def handle_cast({:register, token, x_id}, map) do
    {:noreply, Map.put(map, token, x_id)}
  end

  def handle_cast({:drop, token}, map) do
    {:noreply, Map.delete(map, token)}
  end

  def handle_call({:get, token}, _from, map) do
    {:reply, Map.get(map, token), map}
  end

  def handle_call({:has, token}, _from, map) do
    {:reply, Map.has_key?(map, token), map}
  end

  def handle_call({:change, token, new_token}, _from, map) do
    if Map.has_key?(map, token) && not Map.has_key?(map, new_token) do
      experiment_id = map[token]
      map = map
            |> Map.delete(token)
            |> Map.put(new_token, experiment_id)
      {:reply, :ok, map}
    else
      {:reply, :error, map}
    end
  end
end
