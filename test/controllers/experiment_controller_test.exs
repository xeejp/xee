defmodule Xee.ExperimentControllerTest do
  use ExUnit.Case, async: false
  use Xee.ConnCase
  use Xee.ExperimentTestHelper
  use Xee.SessionTestHelper, controller: Xee.ExperimentController

  alias Xee.User

  setup do
    Mix.Tasks.Ecto.Migrate.run(["--all", "Xee.Repo"]);
    changeset = User.changeset(%User{}, %{name: "a", password: "abcde"})
    User.create(changeset, Xee.Repo)

    on_exit fn ->
      Mix.Tasks.Ecto.Rollback.run(["--all", "Xee.Repo"])
    end
  end

  test "get as a participant without experiment" do
    xid = "test"

    conn = conn()
            |> with_session_and_flash
            |> action :index, %{"xid" => xid}
    assert get_flash(conn, :error) == "Not Exists Experiment ID"
  end

  test "get as a participant with using shortcut token" do
    token = "test"
    xid  = Xee.TokenGenerator.generate
    u_id = Xee.TokenGenerator.generate

    Xee.ExperimentServer.create(xid, test_experiment, %{experiment: test_experiment})
    Xee.TokenServer.register(token, xid)
    conn = conn()
            |> with_session_and_flash
            |> put_session(:u_id, u_id)
            |> put_session(:xid, xid)
    conn = %{conn | private: Map.put(conn.private, :phoenix_endpoint, @endpoint)}
            |> action :shortcut, %{"token" => " \n \t #{token} \t\n "}

    Xee.TokenServer.drop(token)
    Xee.ExperimentServer.remove(xid)

    assert xid == get_session(conn, :xid)
    assert u_id == get_session(conn, :u_id)
    assert conn.status == 200
  end

  test "get as a participant successfully" do
    token = "test"
    xid  = Xee.TokenGenerator.generate
    u_id = Xee.TokenGenerator.generate

    Xee.ExperimentServer.create(xid, test_experiment, %{experiment: test_experiment})
    Xee.TokenServer.register(token, xid)
    conn = conn()
            |> with_session_and_flash
            |> put_session(:u_id, u_id)
            |> put_session(:xid, xid)
    conn = %{conn | private: Map.put(conn.private, :phoenix_endpoint, @endpoint)}
            |> action :index, %{"xid" => xid}
    Xee.TokenServer.drop(token)
    Xee.ExperimentServer.remove(xid)

    assert xid == get_session(conn, :xid)
    assert u_id == get_session(conn, :u_id)
    assert conn.status == 200
    assert html_response(conn, 200) =~ "// participant" # from experiments/test/participant.js
  end

  test "get as a host successfully" do
    xid  = Xee.TokenGenerator.generate
    user = Xee.Repo.get_by(User, name: "a")
    Xee.ExperimentServer.create(xid, test_experiment, %{experiment: test_experiment})

    # has experiment
    Xee.HostServer.register(user.id, xid)
    conn = conn()
            |> with_session_and_flash
            |> assign(:host, user)
    conn = %{conn | private: Map.put(conn.private, :phoenix_endpoint, @endpoint)}
            |> action :host, %{"xid" => xid}

    Xee.HostServer.drop(user.id, xid)
    Xee.ExperimentServer.remove(xid)

    assert conn.status == 200
    assert html_response(conn, 200) =~ "// host" # from experiments/test/participant.js
  end
end
