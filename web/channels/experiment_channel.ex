defmodule Xee.ExperimentChannel do
  use Xee.Web, :channel
  alias Xee.Experiment
  alias Xee.ExperimentServer

  require Logger

  @wrong_token_error {:error, %{reason: "wrong token"}}
  @wrong_xid_error {:error, %{reason: "wrong xid"}}

  def join("x:" <> xid, %{"token" => token}, socket) do
    if ExperimentServer.has?(xid) do
      case Onetime.pop(Xee.channel_token_onetime, token) do
        {:ok, {:host, ^xid}} ->
          socket = socket
                    |> assign(:user, :host)
                    |> assign(:xid, xid)
          {:ok, socket}
        {:ok, {:participant, ^xid, participant_id}} ->
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
  end

  def handle_in("stop", func, socket) when is_function(func) do
    func.()
    {:stop, %{reason: nil}, socket}
  end

  def handle_in("stop", reason, socket) do
    {:stop, %{reason: reason}, socket}
  end

  def handle_in("fetch", _, socket) do
    xid = socket.assigns[:xid]
    data = ExperimentServer.fetch(xid)
    case socket.assigns[:user] do
      :host -> broadcast! socket, "update", %{to: :host, body: data["host"]}
      participant_id -> broadcast! socket, "update", %{to: participant_id, body: data["participant"][participant_id]}
    end
    {:noreply, socket}
  end

  def handle_in("client", %{"body" => data}, socket) do
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

  intercept ["update"]

  def handle_out("update", %{to: user, body: body} = info, socket) do
    if socket.assigns[:user] == user do
      push socket, "update", %{body: body}
    end
    {:noreply, socket}
  end

  def handle_out(event, data, socket) do
    push socket, event, data
    {:noreply, socket}
  end
end
