defmodule Xee.Experiment do
  use GenServer
  require Logger

  defstruct theme_id: nil, module: nil, external: false, host: nil, participant: nil

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

  def attach_meta(pid, host_id, token) do
    meta = %{
      host_id: host_id,
      token: token
    }
    GenServer.cast(pid, {:script, {:receive_meta, [meta]}})
  end

  def fetch(pid) do
    GenServer.call(pid, :fetch)
  end

  def join(pid, id) do
    GenServer.cast(pid, {:script, {:join, [id]}})
  end

  def message(pid, message, token) do
    GenServer.cast(pid, {:script, {:handle_message, [message, token]}, token})
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
            experiment_messages = Map.get(result, "experiment", %{})
            redirect = Map.get(result, "redirect", %{})
            broadcast_message(xid, host, participant, experiment_messages, redirect)
            {:noreply, {xid, experiment, Map.drop(result, ["host", "participant", "redirect", "experiment"])}}
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

  def broadcast_message(xid, host, participant, experiment, redirect) do
    host_task = Task.async(fn ->
      if host != nil do
        Xee.Endpoint.broadcast!(form_topic(xid), "message", %{to: :host, body: host})
      end
    end)
    # Redirect
    redirect = Enum.map(redirect, fn {id, redirect} ->
      Task.async(fn ->
        Xee.Endpoint.broadcast!(form_topic(xid), "redirect", %{to: id, body: redirect})
      end)
    end)
    # Participant
    participant = Enum.map(participant, fn {id, data} ->
      Task.async(fn ->
        Xee.Endpoint.broadcast!(form_topic(xid), "message", %{to: id, body: data})
      end)
    end)
    # Experiment
    experiment = Enum.map(experiment, fn {token, data} ->
      redirect = Map.get(data, :redirect)
      message = Map.get(data, :message)
      Task.async(fn ->
        target_xid = Xee.TokenServer.get(token)
        if Xee.HostServer.has_same_host?(xid, target_xid) do
          if not is_nil(redirect) do
            dest = Xee.TokenServer.get(redirect)
            Xee.Endpoint.broadcast!(form_topic(target_xid), "redirect", %{to: :all, body: dest})
          end
          if not is_nil(message) do
            pid = Xee.ExperimentServer.get(target_xid)
            token = Xee.TokenServer.get_token(xid)
            Xee.Experiment.message(pid, message, token)
          end
        end
      end)
    end)

    Enum.map(experiment, &Task.await/1)
    Enum.map(participant, &Task.await/1)
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
