defmodule Xee.Experiment do
  use GenServer
  use Supervisor

  defstruct theme_id: nil, module: nil, host: nil, participant: nil

  defmodule State do
    def start_link, do: Agent.start_link fn -> nil end
    def update(pid, data), do: Agent.update pid, fn _ -> data end
    def get(pid), do: Agent.get pid, fn x -> x end
  end

  def start_link(experiment, xid) do
    res = {:ok, sup} = Supervisor.start_link([], strategy: :one_for_one)
    {:ok, state} = Supervisor.start_child(sup, worker(__MODULE__.State, []))
    {:ok, pid} = Supervisor.start_child(sup, worker(GenServer, [__MODULE__, {experiment, xid, state}]))
    res
  end

  def init({experiment, xid, state}) do
    case call_script(experiment, :init, []) do
      {:ok, result} ->
        State.update(state, result)
        Xee.ExperimentServer.set_pid(xid, self)
        {:ok, {xid, experiment, state}}
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
    GenServer.cast(pid, {:script, {:receive, [received, participant_id]}, participant_id})
  end

  def client(pid, received) do
    GenServer.cast(pid, {:script, {:receive, [received]}, :host})
  end

  def handle_call(:fetch, _from, {_xid, _experiment, state_pid} = state) do
    data = State.get(state_pid)
    {:reply, data, state}
  end

  def handle_cast({:script, args}, state), do: handle_cast({:script, args, nil}, state)

  def handle_cast({:script, {func, args}, sender}, {xid, experiment, state_pid} = state) do
    %{"data" => data, "host" => host, "participant" => participant} = State.get(state_pid)
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
            State.update(state_pid, result)
            if sender == :host || host != new_host do
              Xee.Endpoint.broadcast!(form_topic(xid), "update", %{body: new_host})
            end
            Enum.each(new_participant, fn {id, new_data} ->
              if sender == id || Map.get(participant, id) != new_data do
                Xee.Endpoint.broadcast!(form_topic(xid, id), "update", %{body: new_data})
              end
            end)
            {:noreply, {xid, experiment, state}}
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
