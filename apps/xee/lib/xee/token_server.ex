defmodule Xee.TokenServer do
  @id_characters 'abcdefghijklmnopqrstuvwxyz'

  @moduledoc """
  The server to store tokens to access experiment easily.
  """
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def reset() do
    GenServer.cast(__MODULE__, {:reset, %{}})
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

  @doc """
  Returns the experiment token.

  This returns nil when token doesn't exist.
  """
  def get_token(xid) do
    GenServer.call(__MODULE__, {:get_token, xid})
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

  @doc "Generate unique experiment ID."
  def generate_id(length \\ 6) do
    GenServer.call(__MODULE__, {:generate_id, length})
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

  def handle_call({:get_token, xid}, _from, map) do
    token = case Enum.filter(map, fn {_token, id} -> id == xid end) do
      [{token, _}] -> token
      _ -> nil
    end
    {:reply, token, map}
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

  def handle_cast({:reset, state}, map) do
    {:noreply, state}
  end

  def handle_call({:generate_id, length}, _from, map) do
    generate = fn (generate) ->
      x_id1 = Enum.map_join(1..length, fn _ -> Enum.take_random @id_characters, 1 end)
      x_id1 = case Enum.member?(Map.values(map), x_id1) do
        true -> generate.(generate)
        false-> x_id1
      end
    end
    x_id = generate.(generate)
    {:reply, x_id, map}
  end
end
