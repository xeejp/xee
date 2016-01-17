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
    x_id = "test"

    conn = conn()
            |> with_session_and_flash
            |> action :index, %{"x_id" => x_id}
    assert get_flash(conn, :error) == "Not Exists Experiment ID"
  end

  test "get as a participant successfully" do
    x_id = "test"
    u_id = Xee.TokenGenerator.generate
    user = Xee.Repo.get_by(User, name: "a")
    Xee.ExperimentServer.create(x_id, test_experiment, %{experiment: test_experiment})
    conn = conn()
            |> with_session_and_flash
            |> assign(:host, user)
            |> put_session(:u_id, u_id)
            |> put_session(:x_id, x_id)
    conn = %{conn | private: Map.put(conn.private, :phoenix_endpoint, @endpoint)}
            |> action :index, %{"x_id" => x_id}

    Xee.HostServer.drop(user.id, x_id)
    Xee.ExperimentServer.remove(x_id)
    assert x_id == get_session(conn, :x_id)
    assert u_id == get_session(conn, :u_id)
    assert conn.status == 200
  end

  test "get as a host without experiment" do
    x_id = "test"
    user = Xee.Repo.get_by(User, name: "a")

    conn = conn()
            |> with_session_and_flash
            |> assign(:host, user)
            |> action :host, %{"x_id" => x_id}
    assert get_flash(conn, :error) == "Not Exists Experiment ID"
  end

  test "get as a host successfully" do
    x_id = "test"
    user = Xee.Repo.get_by(User, name: "a")
    Xee.ExperimentServer.create(x_id, test_experiment, %{experiment: test_experiment})

    # has experiment
    Xee.HostServer.register(user.id, x_id)
    conn = conn()
            |> with_session_and_flash
            |> assign(:host, user)
    conn = %{conn | private: Map.put(conn.private, :phoenix_endpoint, @endpoint)}
            |> action :host, %{"x_id" => x_id}

    Xee.HostServer.drop(user.id, x_id)
    Xee.ExperimentServer.remove(x_id)
    assert conn.status == 200
  end

  test "get as a host without signin" do
    conn = get conn(), "/experiment/test/host"
    assert get_flash(conn, :error) == "You need to be signed in to view this page"
  end
end
