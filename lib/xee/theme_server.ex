defmodule Xee.ThemeServer do
  @moduledoc """
  The server to store experiment themes.
  """

  def experiment(name, file: file, host: host, participant: participant, granted: granted) do
    [{module, _} | _] = Code.load_file(file)
    host = File.read!(host)
    participant = File.read!(participant)
    experiment = %Xee.Experiment{theme_id: name, module: module, host: host, participant: participant}
    granted = if granted == nil do
      nil
    else
      MapSet.new(granted)
    end
    theme = %Xee.Theme{experiment: experiment, id: name, name: name, playnum: 0, lastupdate: 0, producer: "", contact: "", manual: "", granted: granted}
    Xee.ThemeServer.register(name, theme)
  end

  def experiment(name, file: file, host: host, participant: participant) do
    experiment(name, file: file, host: host, participant: participant, granted: nil)
  end

  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Loads experiments from file.
  """
  def load(experiments_file) do
    Code.require_file(experiments_file)
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
