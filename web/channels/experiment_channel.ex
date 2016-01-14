defmodule Xee.ExperimentChannel do
  use Xee.Web, :channel
  alias Xee.Experiment
  alias Xee.ExperimentServer

  @wrong_token_error {:error, %{reason: "wrong token"}}
  @wrong_xid_error {:error, %{reason: "wrong xid"}}

  def join("x:" <> topic, %{"token" => token}, socket) do
    case String.split(topic, ":") do
      [xid, "host"] ->
        if ExperimentServer.has?(xid) do
          case Onetime.pop(Xee.host_onetime, token) do
            {:ok, {:host, ^xid}} ->
              socket = socket
                        |> assign(:user, :host)
                        |> assign(:xid, xid)
              {:ok, socket}
            _ -> @wrong_token_error
          end
        else
          @wrong_xid_error
        end
      [xid, "participant", participant_id] ->
        if ExperimentServer.has?(xid) do
          case Onetime.pop(Xee.participant_onetime, token) do
            {:ok, {:participant, ^xid, ^participant_id}} ->
              socket = socket
                        |> assign(:user, participant_id)
                        |> assign(:xid, xid)
              ExperimentServer.join(xid, participant_id)
              {:ok, socket}
            _ -> @wrong_token_error
          end
        else
          @wrong_xid_error
        end
      _ -> {:error, %{reason: "wrong topic #{topic}"}}
    end
  end

  def handle_in("stop", func, socket) when is_function(func) do
    func.()
    {:stop, %{reason: nil}, socket}
  end

  def handle_in("stop", reason, socket) do
    {:stop, %{reason: reason}, socket}
  end

  def handle_in("client", data, socket) do
    data = Poison.encode!(data)
    name = ExperimentServer.get(socket.assigns[:xid])
    if is_nil(name) do
      {:stop, "wrong xid", socket}
    else
      case socket.assigns[:user] do
        :host -> Experiment.client(name, data)
        participant_id -> Experiment.client(name, data, participant_id)
      end
      {:noreply, socket}
    end
  end
end
