defmodule XeeWeb.AuthenticationPlugTest do
  use ExUnit.Case, async: true
  use Plug.Test
  use XeeWeb.SessionTestHelper

  alias Xee.User

  @opts Xee.AuthenticationPlug.init([])

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Xee.Repo)
    changeset = User.changeset(%User{}, %{name: "a", password: "abcde"})
    User.create(changeset, Xee.Repo)
    :ok
  end

  test "signed in" do
    user = Xee.Repo.get_by(User, name: "a")
    conn = conn(:get, "/")
            |> with_session_and_flash
            |> put_session(:current_user, user.id)
            |> Xee.AuthenticationPlug.call(@opts)
    assert nil != conn.assigns[:host]
  end

  test "not signed in" do
    conn = conn(:get, "/")
            |> with_session_and_flash
    conn = Xee.AuthenticationPlug.call(conn, @opts)
    assert nil == conn.assigns[:host]
  end
end
