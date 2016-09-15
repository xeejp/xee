defmodule Xee.SessionController do
  use Xee.Web, :controller
  alias Xee.User

  @doc """
  Showing login page
  """
  def new(conn, _params) do
    render conn, "new.html"
  end

  @doc """
  Login
  """
  def create(conn, %{"session" => session_params}) do
    case Xee.Session.login(session_params, Xee.Repo) do
      {:ok, user} ->
        conn
        |> put_session(:current_user, user.id)
        |> put_flash(:info, "Logged in.")
        |> put_flash(:intro, "false")
        |> redirect(to: "/host")
      :error ->
        conn
        |> put_flash(:info, "Name or password is incorrect.")
        |> render("new.html")
    end
  end
  @doc """
  Logout
  """
  def delete(conn, _) do
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, "Logged out.")
    |> redirect(to: "/")
  end
end

