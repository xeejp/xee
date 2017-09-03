defmodule Xee.RegistrationController do
  use Xee.Web, :controller
  alias Xee.User

  @doc """
  Showing register page.
  """
  def new(conn, _params) do
    changeset = User.changeset(%User{}, :invalid)
    render conn, "new.html", changeset: changeset
  end

  @doc """
  Registration new user.
  """
  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)
    ip = conn.remote_ip |> Tuple.to_list |> Enum.join(".")

    case User.create(changeset, Xee.Repo) do
      {:ok, user} ->
        conn
        |> put_session(:current_user, user.id)
        |> put_flash(:info, "Welcome to Xee!")
        |> redirect(to: "/host?intro=true")
      {:error, changeset} ->
        conn
        |> put_flash(:info, "Failed to registration.")
        |> render("new.html", changeset: changeset)
    end
  end
end

