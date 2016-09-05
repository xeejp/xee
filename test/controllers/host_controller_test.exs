defmodule Xee.HostControllerTest do
  use Xee.ConnCase
  use ExUnit.Case, async: false
  use Xee.SessionTestHelper, controller: Xee.HostController
  use Xee.ExperimentTestHelper

  alias Xee.User

  setup do
    Xee.ThemeServer.drop_all()
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
      path: "experiments/test",
      file: "test.exs",
      host: "host.js",
      participant: "participant.js"
    user = Xee.Repo.get_by(User, name: "a")
    conn = build_conn()
            |> assign(:host, user)
            |> action(:experiment)
    assert html_response(conn, 200) =~ "実験作成"
  end

  test "GET /host/experiment?theme_id=THEME_ID" do
    Xee.ThemeServer.experiment "test1",
      path: "experiments/test",
      file: "test.exs",
      host: "host.js",
      participant: "participant.js"
    Xee.ThemeServer.experiment "test2",
      path: "experiments/test",
      file: "test.exs",
      host: "host.js",
      participant: "participant.js"
    user = Xee.Repo.get_by(User, name: "a")
    conn = build_conn()
            |> assign(:host, user)
            |> action(:experiment, %{"theme_id" => "test1"})
    assert html_response(conn, 200) =~ "value=\"test1\" selected"
    conn = build_conn()
            |> assign(:host, user)
            |> action(:experiment, %{"theme_id" => "test2"})
    assert html_response(conn, 200) =~ "value=\"test2\" selected"
  end

  test "GET /host/experiment with no themes" do
    user = Xee.Repo.get_by(User, name: "a")
    conn = build_conn()
            |> with_session_and_flash
            |> assign(:host, user)
            |> action(:experiment)
    assert get_flash(conn, :error) == "There are no themes"
  end

  test "create action must fail when one or more of required fields are blank" do
    Xee.ThemeServer.experiment "test",
      path: "experiments/test",
      file: "test.exs",
      host: "host.js",
      participant: "participant.js"
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
      path: "experiments/test",
      file: "test.exs",
      host: "host.js",
      participant: "participant.js"
    x_token = "test"
    user = Xee.Repo.get_by(User, name: "a")
    conn = build_conn()
            |> with_session_and_flash
            |> assign(:host, user)
            |> action(:create, %{"experiment_name" => "test1", "theme" => "test", "x_token" => x_token})
    assert Xee.TokenServer.has?(x_token)
    xid = Xee.TokenServer.get(x_token)
    assert Xee.ExperimentServer.has?(xid)
    assert Xee.HostServer.has?(user.id, xid)
  end

  test "POST /host/remove" do
    Xee.ThemeServer.experiment "test",
      path: "experiments/test",
      file: "test.exs",
      host: "host.js",
      participant: "participant.js"

    user = Xee.Repo.get_by(User, name: "a")
    name = "test1"
    x_token = "test1"
    xid = Xee.TokenGenerator.generate
    xtheme = Xee.ThemeServer.get("test")
    Xee.TokenServer.register(x_token, xid)
    Xee.ExperimentServer.create(xid, xtheme.experiment, %{name: name, experiment: xtheme.experiment, theme: xtheme.name, x_token: x_token, xid: xid})
    Xee.HostServer.register(user.id, xid)

    user = Xee.Repo.get_by(User, name: "a")
    conn = build_conn()
            |> with_session_and_flash
            |> assign(:host, user)
            |> action(:create, %{"experiment_name" => "test1", "theme" => "test", "x_token" => x_token})
    xid = Xee.TokenServer.get(x_token)
    pid = Xee.ExperimentServer.get(xid)
  end
end
