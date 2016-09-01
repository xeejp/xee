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

  defp get_module_from_file(file) do
    [{module, _} | _] = Code.load_file(file)
    module
  end

  def experiment(name, params) do
    params = params
              |> Keyword.put_new(:granted, nil)
              |> Keyword.put_new(:description, nil)
    file = Keyword.get(params, :file)
    host = Keyword.get(params, :host)
    participant = Keyword.get(params, :participant)
    granted = Keyword.get(params, :granted)
    description = Keyword.get(params, :description)

    module = get_module_from_file(file)
    files = apply(module, :require_files, [])
    dir = Path.dirname(file)
    files = Enum.map(files, fn file -> Path.expand(file, dir) end)
    watch_files = files ++ [file, host, participant]
    unless is_nil(description) do
      watch_files = [description | watch_files]
    end
    do_and_watch(watch_files, fn -> load_from_file(name, file, files, host, participant, description, granted) end)
  end

  defp load_from_file(name, file, files, host, participant, description, granted) do
    module = get_module_from_file(file)
    for file <- files do
      Code.load_file(file)
    end
    host = File.read!(host)
    participant = File.read!(participant)
    description = unless is_nil(description) do
      File.read!(description)
    else
      nil
    end
    experiment = %Xee.Experiment{theme_id: name, module: module, host: host, participant: participant}
    granted = if granted == nil do
      nil
    else
      MapSet.new(granted)
    end
    theme = %Xee.Theme{experiment: experiment, id: name, name: name, description: description, granted: granted}
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
  Registers the theme with a key.
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
  Returns the theme for a specific key.
  """
  def get(key) do
    Agent.get(__MODULE__, fn map -> map[key] end)
  end

  @doc """
  Delete the themes for a specific key.
  """
  def delete(key) do
    Agent.update(__MODULE__, fn map -> Map.delete(map, key) end)
  end

  @doc """
  Drops all themes.
  """
  def drop_all() do
    Agent.update(__MODULE__, fn _ -> %{} end)
  end
end
