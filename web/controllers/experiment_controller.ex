defmodule Xee.ExperimentController do
  use Xee.Web, :controller

  plug Xee.AuthenticationPlug when action in [:host]

  def index(conn, %{"x_id" => x_id}) do
    if Xee.ExperimentServer.has?(x_id) do
      {conn, u_id} = case {get_session(conn, :u_id), get_session(conn, :x_id)} do
        {u_id, ^x_id} -> {conn, u_id}
        _ ->
          u_id = Xee.TokenGenerator.generate
          conn = conn
                  |> put_session(:u_id, u_id)
                  |> put_session(:x_id, x_id)
          {conn, u_id}
      end
      token = Xee.TokenGenerator.generate
      Onetime.register(Xee.participant_onetime, token, %{participant_id: u_id, experiment_id: x_id})
      render conn, "index.html", token: token, topic: "x:" <> x_id <> ":participant:" <> u_id
    else
      conn
      |> put_flash(:error, "Not Exists Experiment ID")
      |> redirect(to: "/")
    end
  end

  def host(conn, %{"x_id" => x_id}) do
    user = Xee.Repo.get(Xee.User, conn.assigns[:host])
    has = Xee.HostServer.has?(user.name, x_id)
    if has do
      token = Xee.TokenGenerator.generate
      Onetime.register(Xee.host_onetime, token, %{host_id: conn.assigns[:current_user], experiment_id: x_id})
      render conn, "host.html", token: token, topic: "x:" <> x_id <> ":host:" <> conn.assigns[:current_user]
    else
      conn
      |> put_flash(:error, "Not Exists Experiment ID")
      |> redirect(to: "/host")
    end
  end
end
