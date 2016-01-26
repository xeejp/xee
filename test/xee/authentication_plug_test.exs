defmodule Xee.AuthenticationPlugTest do
  use ExUnit.Case, async: true
  use Plug.Test
  use Xee.SessionTestHelper

  alias Xee.User

  @opts Xee.AuthenticationPlug.init([])

  setup do
    Mix.Tasks.Ecto.Migrate.run(["--all", "Xee.Repo"]);
    changeset = User.changeset(%User{}, %{name: "a", password: "abcde"})
    User.create(changeset, Xee.Repo)

    on_exit fn ->
      Mix.Tasks.Ecto.Rollback.run(["--all", "Xee.Repo"])
    end
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
