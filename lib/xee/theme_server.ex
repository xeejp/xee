defmodule Xee.ThemeServer do
  @moduledoc """
  The server to store experiment themes.
  """
  require Logger

  defp do_and_watch(files, func) do
    func.()
    if Mix.env == :dev do
      Fwatch.watch_file(files, fn _, _ ->
        func.()
      end)
    end
  end

  def experiment(name, file: file, host: host, participant: participant, granted: granted) do
    do_and_watch([file, host, participant], fn -> load_from_file(name, file, host, participant, granted) end)
  end

  def experiment(name, file: file, host: host, participant: participant) do
    experiment(name, file: file, host: host, participant: participant, granted: nil)
  end

  defp load_from_file(name, file, host, participant, granted) do
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
    apply(module, :install, [])
  end

  def start_link() do
    result = Agent.start_link(fn -> %{} end, name: __MODULE__)
    config = Application.fetch_env!(:xee, __MODULE__)
    files = Keyword.fetch!(config, :files)
    for file <- files do
      load(file)
    end
    result
  end

  @doc """
  Loads experiments from file.
  """
  def load(experiments_file) do
    do_and_watch(experiments_file, fn ->
      Logger.debug("#{inspect experiments_file}")
      Code.load_file(experiments_file)
    end)
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
