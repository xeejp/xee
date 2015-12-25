defmodule Xee.ThemeServer do
  @moduledoc """
  The server to store experiment themes.
  """

  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Registers a theme with a key.
  """
  def register(key, theme) do
    Agent.update(__MODULE__, fn map -> Map.put(map, key, theme) end)
  end

  @doc """
  Returns a map containing all themes.
  """
  def get_all() do
    Agent.get(__MODULE__, fn map -> map end)
  end

  @doc """
  Returns a theme for the given key.
  """
  def get(key) do
    Agent.get(__MODULE__, fn map -> map[key] end)
  end
end
