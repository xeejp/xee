defmodule Xee.ExperimentChannel do
  use Xee.Web, :channel
  alias Xee.Experiment
  alias Xee.ExperimentServer

  require Logger

  @wrong_token_error {:error, %{reason: "wrong token"}}
  @wrong_xid_error {:error, %{reason: "wrong xid"}}

  def join("x:" <> xid, %{"token" => token}, socket) do
    if ExperimentServer.has?(xid) do
      case Phoenix.Token.verify(Xee.Endpoint, "experiment", token) do
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

  def handle_in("ping", _, socket) do
    {:noreply, socket}
  end

  intercept ["update", "message", "redirect"]
  @events ["update", "message", "redirect"]

  def handle_out(event, %{to: user, body: body} = info, socket) when event in @events do
    send? = case {socket.assigns[:user], user} do
      {user, user} -> true
      {:host, :participant} -> false
      {_, :participant} -> true
      _ -> false
    end
    if send? do
      push socket, event, %{body: body}
    end
    {:noreply, socket}
  end

  def handle_out(event, data, socket) do
    push socket, event, data
    {:noreply, socket}
  end
end
