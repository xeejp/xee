defmodule Xee.ExperimentControllerTest do
  use Xee.ConnCase
  use Xee.ExperimentTestHelper
  use Xee.SessionTestHelper
  use ExUnit.Case, async: false

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

  test "not exists experiment" do
    conn = conn()
            |> with_session_and_flash
            |> put_session(:u_id, Xee.TokenGenerator.generate)
            |> get "/experiment/test"
    assert conn.resp_body =~ "Not Exists Experiment ID"
  end

  test "exists experiment" do
    x_id = "test"
    Xee.ExperimentServer.create(x_id, test_experiment)

    conn = conn()
            |> with_session_and_flash
            |> put_session(:u_id, Xee.TokenGenerator.generate)
            |> put_session(:x_id, x_id)
            |> get "/experiment/test"
    assert x_id == get_session(conn, :x_id)
    assert nil  != get_session(conn, :u_id)
    assert conn.status == 200
  end

  test "signed in" do
    x_id = "test"
    user = Xee.Repo.get_by(User, name: "a")

    # not has experiment
    conn = conn()
            |> with_session_and_flash
            |> put_session(:current_user, user.id)
            |> get "/experiment/test"
    assert conn.resp_body =~ "Not Exists Experiment ID"

    # has experiment
    Xee.HostServer.register("a", x_id, %{})
    conn = conn()
            |> with_session_and_flash
            |> put_session(:current_user, user.id)
            |> get "/experiment/test"
    assert conn.status == 200
  end

  test "not signed in" do
    conn = conn()
            |> with_session_and_flash
            |> get "/"
    assert conn.resp_body =~ "You need to be signed in to view this page"
  end
end
