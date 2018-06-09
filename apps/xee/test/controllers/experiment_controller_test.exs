defmodule XeeWeb.ExperimentControllerTest do
  use ExUnit.Case, async: false
  use XeeWeb.ConnCase
  use XeeWeb.ExperimentTestHelper
  use XeeWeb.SessionTestHelper, controller: XeeWeb.ExperimentController

  alias Xee.User

  setup do
    changeset = User.changeset(%User{}, %{name: "a", password: "abcde"})
    User.create(changeset, Xee.Repo)
    :ok
  end

  test "get as a participant without experiment" do
    xid = "test"

    conn = build_conn()
            |> with_session_and_flash
            |> action(:index, %{"xid" => xid})
    assert get_flash(conn, :error) == "Not Exists Experiment ID"
  end

  test "get as a participant with using shortcut token" do
    token = "test"
    theme = "test"
    xid  = Xee.TokenGenerator.generate
    u_id = Xee.TokenGenerator.generate

    Xee.ExperimentServer.create(xid, test_experiment, %{experiment: test_experiment, x_token: token, theme: theme})
    Xee.TokenServer.register(token, xid)
    conn = build_conn()
            |> with_session_and_flash
            |> put_session(:u_id, u_id)
            |> put_session(:xid, xid)
    conn = %{conn | private: Map.put(conn.private, :phoenix_endpoint, @endpoint)}
            |> action(:shortcut, %{"token" => " \n \t #{token} \t\n "})

    Xee.TokenServer.drop(token)
    Xee.ExperimentServer.remove(xid)

    assert xid == get_session(conn, :xid)
    assert u_id == get_session(conn, :u_id)
    assert conn.status == 200
  end

  test "get as a participant successfully" do
    token = "test"
    theme = "test"
    xid  = Xee.TokenGenerator.generate
    u_id = Xee.TokenGenerator.generate

    Xee.ExperimentServer.create(xid, test_experiment, %{experiment: test_experiment, x_token: token, theme: theme})
    Xee.TokenServer.register(token, xid)
    conn = build_conn()
            |> with_session_and_flash
            |> put_session(:u_id, u_id)
            |> put_session(:xid, xid)
    conn = %{conn | private: Map.put(conn.private, :phoenix_endpoint, @endpoint)}
            |> action(:index, %{"xid" => xid})
    Xee.TokenServer.drop(token)
    Xee.ExperimentServer.remove(xid)

    assert xid == get_session(conn, :xid)
    assert u_id == get_session(conn, :u_id)
    assert conn.status == 200
    assert html_response(conn, 200) =~ "/experiment/#{xid}/participant.js"
  end

  test "get as a host successfully" do
    xid  = Xee.TokenGenerator.generate
    user = Xee.Repo.get_by(User, name: "a")
    token = "test"
    theme = "test"
    Xee.ExperimentServer.create(xid, test_experiment, %{experiment: test_experiment, x_token: token, theme: theme})

    # has experiment
    Xee.HostServer.register(user.id, xid)
    conn = build_conn()
            |> with_session_and_flash
            |> assign(:host, user)
    conn = %{conn | private: Map.put(conn.private, :phoenix_endpoint, @endpoint)}
            |> action(:host, %{"xid" => xid})

    Xee.HostServer.drop(user.id, xid)
    Xee.ExperimentServer.remove(xid)

    assert conn.status == 200
    assert html_response(conn, 200) =~ "/experiment/#{xid}/host.js"
  end

  test "get participant.js" do
    token = "test"
    theme = "test"
    xid  = Xee.TokenGenerator.generate
    u_id = Xee.TokenGenerator.generate

    Xee.ExperimentServer.create(xid, test_experiment, %{experiment: test_experiment, x_token: token, theme: theme})
    conn = build_conn()
            |> with_session_and_flash
            |> put_session(:u_id, u_id)
            |> put_session(:xid, xid)
    conn = %{conn | private: Map.put(conn.private, :phoenix_endpoint, @endpoint)}
            |> action(:participant_script, %{"xid" => xid})
    Xee.ExperimentServer.remove(xid)

    assert xid == get_session(conn, :xid)
    assert u_id == get_session(conn, :u_id)
    assert conn.status == 200
    assert response_content_type(conn, :javascript) =~ "charset=utf-8"
    assert response(conn, 200) =~ "// participant" # from experiments/test/participant.js
  end

  test "get host.js" do
    xid  = Xee.TokenGenerator.generate
    user = Xee.Repo.get_by(User, name: "a")
    token = "test"
    theme = "test"
    Xee.ExperimentServer.create(xid, test_experiment, %{experiment: test_experiment, x_token: token, theme: theme})

    # has experiment
    Xee.HostServer.register(user.id, xid)
    conn = build_conn()
            |> with_session_and_flash
            |> assign(:host, user)
    conn = %{conn | private: Map.put(conn.private, :phoenix_endpoint, @endpoint)}
            |> action(:host_script, %{"xid" => xid})

    Xee.HostServer.drop(user.id, xid)
    Xee.ExperimentServer.remove(xid)

    assert conn.status == 200
    assert response_content_type(conn, :javascript) =~ "charset=utf-8"
    assert response(conn, 200) =~ "// host" # from experiments/test/host.js
  end

  test "get as a participant with using :controll successfully" do
    xid  = Xee.TokenGenerator.generate
    id = "aaaa"
    token = "test"
    theme = "test"
    user = Xee.Repo.get_by(User, name: "a")
    Xee.ExperimentServer.create(xid, test_experiment, %{experiment: test_experiment, x_token: token, theme: theme})

    # has experiment
    Xee.HostServer.register(user.id, xid)
    conn = build_conn()
            |> with_session_and_flash
            |> assign(:host, user)
    conn = %{conn | private: Map.put(conn.private, :phoenix_endpoint, @endpoint)}
            |> action(:control, %{"xid" => xid, "id" => "aaaa"})

    Xee.HostServer.drop(user.id, xid)
    Xee.ExperimentServer.remove(xid)

    assert conn.status == 200
    assert html_response(conn, 200) =~ "/experiment/#{xid}/participant.js"
  end
end
