defmodule Xee.Session do
  alias Xee.User

  @doc """
  Login
  """
  def login(params, repo) do
    user = repo.get_by(User, name: String.downcase(params["name"]))
    case authenticate(user, params["password"]) do
      true -> {:ok, user}
      _    -> :error
    end
  end

  @doc """
  Authentication
  """
  defp authenticate(user, password) do
    case user do
      nil -> false
      _   -> Comeonin.Bcrypt.checkpw(password, user.crypted_password)
    end
  end

  @doc """
  Showing current login user.
  """
  def current_user(conn) do
    id = Plug.Conn.get_session(conn, :current_user)
    if id, do: Xee.Repo.get(User, id)
  end


  @doc """
  Checking whether logged in or not.
  """
  def logged_in?(conn) do
    !!current_user(conn)
  end
end
