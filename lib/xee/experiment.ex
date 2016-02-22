defmodule Xee.Experiment do
  use GenServer

  defstruct theme_id: nil, module: nil, host: nil, participant: nil

  def start_link(experiment, xid) do
    GenServer.start_link(__MODULE__, {experiment, xid})
  end

  def init({experiment, xid}) do
    case call_script(experiment, :init, []) do
      {:ok, result} -> {:ok, {xid, experiment, result}}
      _ -> :error
    end
  end

  def fetch(pid) do
    GenServer.call(pid, :fetch)
  end

  def join(pid, id) do
    GenServer.cast(pid, {:script, {:join, [id]}})
  end

  def client(pid, received, participant_id) do
    GenServer.cast(pid, {:script, {:receive, [received, participant_id]}})
  end

  def client(pid, received) do
    GenServer.cast(pid, {:script, {:receive, [received]}})
  end

  def handle_call(:fetch, _from, {_xid, _experiment, data} = state) do
    {:reply, data, state}
  end

  def handle_cast({:script, {func, args}}, {xid, experiment, %{"data" => data, "host" => host, "participant" => participant}} = state) do
    experiment = if Mix.env == :dev do
      Xee.ThemeServer.get(experiment.theme_id).experiment
    else
      experiment
    end
    args = [data] ++ args
    case call_script(experiment, func, args) do
      {:ok, result} ->
        case result do
          %{"host" => new_host, "participant" => new_participant} when is_map(new_participant) ->
            if host != new_host do
              Xee.Endpoint.broadcast!(form_topic(xid), "update", %{body: new_host})
            end
            Enum.each(new_participant, fn {id, new_data} ->
              if Map.get(participant, id) != new_data do
                Xee.Endpoint.broadcast!(form_topic(xid, id), "update", %{body: new_data})
              end
            end)
            {:noreply, {xid, experiment, result}}
          _ -> {:stop, "The result is wrong: #{inspect result}", state}
        end
      _ -> {:stop, "The script failed. #{args}", state}
    end
  end

  def call_script(experiment, func, args) do
    apply(experiment.module, func, args)
  end

  @doc "Forms a topic name for host."
  def form_topic(xid) do
    "x:" <> xid <> ":" <> "host"
  end

  @doc "Forms a topic name for participant."
  def form_topic(xid, participant_id) do
    "x:" <> xid <> ":" <> "participant" <> ":" <> participant_id
  end
end
