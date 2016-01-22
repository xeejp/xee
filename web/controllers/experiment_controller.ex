defmodule Xee.ExperimentController do
  use Xee.Web, :controller

  plug Xee.AuthenticationPlug when action in [:host]

  def shortcut(conn, %{"token" => token}) do
    xid = Xee.TokenServer.get(token)
    index(conn, %{"xid" => xid})
  end

  def index(conn, %{"xid" => xid}) do
    if Xee.ExperimentServer.has?(xid) do
      {conn, u_id} = case {get_session(conn, :u_id), get_session(conn, :xid)} do
        {u_id, ^xid} when u_id != nil -> {conn, u_id}
        _ ->
          u_id = Xee.TokenGenerator.generate
          conn = conn
                  |> put_session(:u_id, u_id)
                  |> put_session(:xid, xid)
          {conn, u_id}
      end
      token = Xee.TokenGenerator.generate
      Onetime.register(Xee.participant_onetime, token, {:participant, xid, u_id})
      js = get_javascript(xid)
      render conn, "index.html", javascript: js, token: token, topic: "x:" <> xid <> ":participant:" <> u_id
    else
      conn
      |> put_flash(:error, "Not Exists Experiment ID")
      |> redirect(to: "/")
    end
  end

  def host(conn, %{"xid" => xid}) do
    user = conn.assigns[:host]
    has = Xee.HostServer.has?(user.id, xid)
    if has do
      token = Xee.TokenGenerator.generate
      Onetime.register(Xee.host_onetime, token, {:host, xid})
      js = get_javascript(xid)
      render conn, "index.html", javascript: js, token: token, topic: "x:" <> xid <> ":host"
    else
      conn
      |> put_flash(:error, "Not Exists Experiment ID")
      |> redirect(to: "/host")
    end
  end

  defp get_javascript(xid) do
    Xee.ExperimentServer.get_info(xid)
            |> Map.get(:experiment)
            |> Map.get(:javascript)
            |> File.read!
  end
end
