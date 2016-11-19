defmodule Xee.ThemeServer do
  @moduledoc """
  The server to store experiment themes.
  """
  require Logger
  @root_dir Path.expand("./../../../../", __DIR__)

  defp do_and_watch(files, func) do
    func.()
    if Mix.env == :dev do
      Fwatch.watch_file(files, fn _, _ ->
        func.()
      end)
    end
  end

  def experiment(name, params) do
    path = Keyword.get(params, :path) |> Path.expand(@root_dir)
    file = Keyword.get(params, :file) |> Path.expand(path)
    module_func = fn -> get_module_from_file(file) end
    module = module_func.()
    require_files = apply(module, :require_files, [])
                    |> Enum.map(fn file -> Path.expand(file, path) end)
    load_from_file(name, path, module_func, require_files, require_files ++ [file], params)
  end

  defp get_module_from_file(file, relative_to \\ nil) do
    [{module, _} | _] = Code.load_file(file, relative_to)
    module
  end

  defp load_from_file(name, path, module_func, require_files, watch_files, params) do
    external = Keyword.get(params, :external, false)
    host = Keyword.get(params, :host)
    participant = Keyword.get(params, :participant)
    {host, participant} = if external do
      {host, participant}
    else
      path = Path.expand(path, @root_dir)
      host = Keyword.get(params, :host) |> Path.expand(path)
      participant = Keyword.get(params, :participant) |> Path.expand(path)
      {host, participant}
    end
    granted = Keyword.get(params, :granted, nil)
    description = Keyword.get(params, :description, nil)
    tags = Keyword.get(params, :tags, [])
    standing_experiments = Keyword.get(params, :standing_experiments, nil)
    watch_files = if external do
      watch_files
    else
      [host, participant] ++ watch_files
    end
    unless is_nil(description) do
      description = Path.expand(description, path)
      watch_files = [description | watch_files]
    end
    do_and_watch(watch_files, fn -> load_from_file(name, module_func, require_files, host, participant, description, external, granted, standing_experiments, tags) end)
  end

  defp load_from_file(name, module_func, require_files, host, participant, description, external, granted, standing_experiments, tags) do
    module = module_func.()
    for file <- require_files do
      Code.load_file(file)
    end
    host = if external, do: host, else: File.read!(host)
    participant = if external, do: participant, else: File.read!(participant)
    description = if not is_nil(description) and not external do
      File.read!(description)
    else
      description
    end
    experiment = %Xee.Experiment{theme_id: name, module: module, host: host, participant: participant, external: external}
    granted = if granted == nil do
      nil
    else
      MapSet.new(granted)
    end
    theme = %Xee.Theme{experiment: experiment, id: name, name: name, description: description, granted: granted, tags: tags}
    Xee.ThemeServer.register(name, theme)
    create_standing_experiment(theme, standing_experiments)
    apply(module, :install, [])
  end

  defp create_standing_experiment(theme, info) do
    cond do
      is_list(info) ->
        Enum.each(info, fn x ->
          if Map.has_key?(x, :name) and Map.has_key?(x, :x_token) do
            xid = Xee.TokenGenerator.generate
            Xee.TokenServer.register(x.x_token, xid)
            Xee.ExperimentServer.create(xid, theme.experiment, %{name: x.name, experiment: theme.experiment, theme: theme.name, x_token: x.x_token, xid: xid})
            Logger.info("[Create Standing Experiment] : #{inspect(info)}")
          end
        end)
      is_map(info) ->
        if Map.has_key?(info, :name) and Map.has_key?(info, :x_token) do
          xid = Xee.TokenGenerator.generate
          Xee.TokenServer.register(info.x_token, xid)
          Xee.ExperimentServer.create(xid, theme.experiment, %{name: info.name, experiment: theme.experiment, theme: theme.name, x_token: info.x_token, xid: xid})
          Logger.info("[Create Standing Experiment] : #{inspect(info)}")
        end
      true -> nil
    end
  end

  def start_link() do
    result = Agent.start_link(fn -> %{} end, name: __MODULE__)

    themes = Application.get_env(:xee, __MODULE__)
    module_themes = themes[:module_themes]
    for {module, params} <- module_themes do
      name = Keyword.get(params, :name)
      if is_nil(name) do
        name = String.slice(Atom.to_string(module), length('Elixir.')..-1)
      end
      path = Keyword.get(params, :path)
      load_from_file(name, path, fn -> module end, [], [], params)
    end

    file_themes = themes[:file_themes]
    for {name, params} <- file_themes do
      experiment(name, params)
    end
    result
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
