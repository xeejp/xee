defmodule Xee.Experiment do
  use GenServer

  defstruct theme_id: nil, script: nil, javascript: nil

  def start_link(experiment, xid) do
    GenServer.start_link(__MODULE__, {experiment, xid})
  end

  def init({experiment, xid}) do
    [command | args] = experiment.script
    case call_script(command, args ++ ["init"]) do
      {0, result} -> {:ok, {xid, experiment, Poison.decode!(result)}}
      _ -> :error
    end
  end

  def fetch(pid) do
    GenServer.call(pid, :fetch)
  end

  def join(pid, id) do
    GenServer.cast(pid, {:script, ["join", id]})
  end

  def client(pid, received, participant_id) do
    GenServer.cast(pid, {:script, ["receive", Poison.encode!(received), participant_id]})
  end

  def client(pid, received) do
    GenServer.cast(pid, {:script, ["receive", Poison.encode!(received)]})
  end

  def handle_call(:fetch, _from, {_xid, _experiment, data} = state) do
    {:reply, data, state}
  end

  def handle_cast({:script, list}, {xid, experiment, %{"data" => data, "host" => host, "participant" => participant}} = state) do
    [command | tail] = experiment.script
    args = tail ++ List.insert_at(list, 1, Poison.encode!(data))
    # command: "python"
    # args: ["script.py", "join", DATA, id]
    case call_script(command, args) do
      {0, result} ->
        case Poison.decode(result) do
          {:ok, result = %{"host" => new_host, "participant" => new_participant}} when is_map(new_participant) ->
            if host != new_host do
              Xee.Endpoint.broadcast!(form_topic(xid), "update", %{payload: new_host})
            end
            Enum.each(new_participant, fn {id, new_data} ->
              unless Map.get(participant, id) |> is_nil do
                Xee.Endpoint.broadcast!(form_topic(xid, id), "update", %{payload: new_data})
              end
            end)
            {:noreply, {xid, experiment, result}}
          _ -> {:stop, "The result is wrong: #{result}", state}
        end
      _ -> {:stop, "The script failed. #{args}", state}
    end
  end

  def call_script(command, args) do
    {output, status} = System.cmd(command, args)
    {status, output}
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
