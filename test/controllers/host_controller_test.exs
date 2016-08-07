defmodule Xee.HostControllerTest do
  use Xee.ConnCase
  use ExUnit.Case, async: false
  use Xee.SessionTestHelper, controller: Xee.HostController
  use Xee.ExperimentTestHelper

  alias Xee.User

  setup do
    changeset = User.changeset(%User{}, %{name: "a", password: "abcde"})
    User.create(changeset, Xee.Repo)
    :ok
  end

  test "GET /host without signin" do
    conn = get build_conn(), "/host"
    assert get_flash(conn, :error) == "You need to be signed in to view this page"
  end

  test "GET /host with signin" do
    user = Xee.Repo.get_by(User, name: "a")
    conn = build_conn()
            |> assign(:host, user)
            |> action(:index)
    assert html_response(conn, 200) =~ "管理者画面"
  end

  test "GET /host/experiment without signin" do
    conn = get build_conn(), "/host/experiment"
    assert get_flash(conn, :error) == "You need to be signed in to view this page"
  end

  test "GET /host/experiment with signin" do
    Xee.ThemeServer.experiment "test",
      file: "experiments/test/test.exs",
      host: "experiments/test/host.js",
      participant: "experiments/test/participant.js"
    user = Xee.Repo.get_by(User, name: "a")
    conn = build_conn()
            |> assign(:host, user)
            |> action(:experiment)
    assert html_response(conn, 200) =~ "実験作成"
  end

  test "GET /host/experiment with no themes" do
    Agent.stop(Xee.ThemeServer)
    Xee.ThemeServer.start_link()
    user = Xee.Repo.get_by(User, name: "a")
    conn = build_conn()
            |> with_session_and_flash
            |> assign(:host, user)
            |> action(:experiment)
    assert get_flash(conn, :error) == "There are no themes"
  end

  test "create action must fail when one or more of required fields are blank" do
    Xee.ThemeServer.experiment "test",
      file: "experiments/test/test.exs",
      host: "experiments/test/host.js",
      participant: "experiments/test/participant.js"
    x_token = "test"
    user = Xee.Repo.get_by(User, name: "a")
    conn = build_conn()
            |> with_session_and_flash
            |> assign(:host, user)
            |> action(:create, %{"experiment_name" => "", "theme" => "test", "x_token" => x_token})
    assert conn.status != 200
    assert get_flash(conn, :error) == "All fields are required"
  end

  test "POST /experiment/create" do
    Xee.ThemeServer.experiment "test",
      file: "experiments/test/test.exs",
      host: "experiments/test/host.js",
      participant: "experiments/test/participant.js"
    x_token = "test"
    user = Xee.Repo.get_by(User, name: "a")
    conn = build_conn()
            |> with_session_and_flash
            |> assign(:host, user)
            |> action(:create, %{"experiment_name" => "test1", "theme" => "test", "x_token" => x_token})
    assert Xee.TokenServer.has?(x_token)
    xid = Xee.TokenServer.get(x_token)
    assert Xee.ExperimentServer.has?(xid)
  end
end
