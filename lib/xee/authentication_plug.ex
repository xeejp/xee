defmodule Xee.AuthenticationPlug do
  import Plug.Conn
  import Phoenix.Controller

  def init(default), do: default

  def call(conn, _default) do
    user = Xee.Session.current_user(conn)
    if user != nil do
      conn |> assign(:host, user)
    else
      conn
      |> put_flash(:error, "You need to be signed in to view this page")
      |> redirect(to: "/login")
      |> halt
    end
  end
end
