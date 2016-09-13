defmodule Xee.Experiment do
  use GenServer
  require Logger

  defstruct theme_id: nil, module: nil, host: nil, participant: nil

  def start_link(experiment, xid) do
    GenServer.start_link(__MODULE__, {experiment, xid})
  end

  def stop(pid) do
    if Process.alive?(pid) do
      GenServer.stop(pid)
    end
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
    GenServer.cast(pid, {:script, {:handle_received, [received, participant_id]}, participant_id})
  end

  def client(pid, received) do
    GenServer.cast(pid, {:script, {:handle_received, [received]}, :host})
  end

  def handle_call(:fetch, _from, {_xid, _experiment, data} = state) do
    {:reply, data, state}
  end

  def handle_cast({:script, args}, state), do: handle_cast({:script, args, nil}, state)

  def handle_cast({:script, {func, args}, sender}, {xid, experiment, %{"data" => data}} = state) do
    if experiment.module.script_type == :data do
      host = Map.get(elem(state, 2), "host")
      participant = Map.get(elem(state, 2), "participant")
    end
    experiment = if Mix.env == :dev do
      Xee.ThemeServer.get(experiment.theme_id).experiment
    else
      experiment
    end
    args = [data] ++ args
    case call_script(experiment, func, args) do
      {:ok, result} ->
        case experiment.module.script_type do
          :data -> 
            case result do
              %{"host" => new_host, "participant" => new_participant} when is_map(new_participant) ->
                broadcast_data(xid, sender, host, new_host, participant, new_participant)
                {:noreply, {xid, experiment, result}}
                _ -> {:stop, "The result is wrong: #{inspect result}", state}
            end
          :message ->
            host = Map.get(result, "host", nil)
            participant = Map.get(result, "participant", %{})
            redirect = Map.get(result, "redirect", %{})
            broadcast_message(xid, host, participant, redirect)
            {:noreply, {xid, experiment, Map.drop(result, ["host", "participant", "redirect"])}}
        end
      {:error, e} ->
        Logger.error(Exception.format(:error, e, System.stacktrace()))
        if experiment.module.script_type == :data do
          case sender do
            nil -> nil
            :host -> Xee.Endpoint.broadcast!(form_topic(xid), "update", %{body: host})
            id -> Xee.Endpoint.broadcast!(form_topic(xid), "update", %{body: Map.get(participant, id)})
          end
        end
        {:noreply, state}
    end
  end

  def broadcast_data(xid, sender, host, new_host, participant, new_participant) do
    host_task = Task.async(fn ->
      if sender == :host || host != new_host do
        Xee.Endpoint.broadcast!(form_topic(xid), "update", %{to: :host, body: new_host})
      end
    end)
    Enum.map(new_participant, fn {id, new_data} ->
      Task.async(fn ->
        if sender == id || Map.get(participant, id) != new_data do
          Xee.Endpoint.broadcast!(form_topic(xid), "update", %{to: id, body: new_data})
        end
      end)
    end)
    |> Enum.map(&Task.await/1)
    Task.await(host_task)
  end

  def broadcast_message(xid, host, participant, redirect) do
    host_task = Task.async(fn ->
      if host != nil do
        Xee.Endpoint.broadcast!(form_topic(xid), "message", %{to: :host, body: host})
      end
    end)
    redirect = Enum.map(redirect, fn {id, redirect} ->
      Task.async(fn ->
        Xee.Endpoint.broadcast!(form_topic(xid), "redirect", %{to: id, body: redirect})
      end)
    end)
    Enum.map(participant, fn {id, data} ->
      Task.async(fn ->
        Xee.Endpoint.broadcast!(form_topic(xid), "message", %{to: id, body: data})
      end)
    end)
    |> Enum.map(&Task.await/1)
    Enum.map(redirect, &Task.await/1)
    Task.await(host_task)
  end

  def call_script(experiment, func, args) do
    try do
      {:ok, result} = apply(experiment.module, func, args)
      result = for {key, value} <- result, into: %{} do
        key = case key do
          key when is_atom(key) -> Atom.to_string(key)
          key -> key
        end
        {key, value}
      end
      {:ok, result}
    rescue
      e -> {:error, e}
    end
  end

  @doc "Forms a topic name."
  def form_topic(xid) do
    "x:" <> xid
  end
end
