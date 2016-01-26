defmodule Xee.HostControllerTest do
  use Xee.ConnCase
  use ExUnit.Case, async: false
  use Xee.SessionTestHelper, controller: Xee.HostController
  use Xee.ExperimentTestHelper

  alias Xee.User

  setup do
    Mix.Tasks.Ecto.Migrate.run(["--all", "Xee.Repo"]);
    changeset = User.changeset(%User{}, %{name: "a", password: "abcde"})
    User.create(changeset, Xee.Repo)

    on_exit fn ->
      Mix.Tasks.Ecto.Rollback.run(["--all", "Xee.Repo"])
    end
  end

  test "GET /host without signin" do
    conn = get conn(), "/host"
    assert get_flash(conn, :error) == "You need to be signed in to view this page"
  end

  test "GET /host with signin" do
    user = Xee.Repo.get_by(User, name: "a")
    conn = conn()
            |> assign(:host, user)
            |> action(:index)
    assert html_response(conn, 200) =~ "管理者画面"
  end

  test "GET /host/experiment without signin" do
    conn = get conn(), "/host/experiment"
    assert get_flash(conn, :error) == "You need to be signed in to view this page"
  end

  test "GET /experiment with signin" do
    user = Xee.Repo.get_by(User, name: "a")
    conn = conn()
            |> assign(:host, user)
            |> action(:experiment)
    assert html_response(conn, 200) =~ "実験作成"
  end

  test "POST /experiment/create" do
    Xee.ThemeServer.register :test, %{id: :t1, name: "Example", playnum: "2", lastupdate: "2015/1/1", producer: "hoge", contact: "aaa@aaa", manual: "", module: test_experiment.module, javascript: test_experiment.javascript}
    x_token = "test"
    user = Xee.Repo.get_by(User, name: "a")
    conn = conn()
            |> with_session_and_flash
            |> assign(:host, user)
            |> action(:create, %{"experiment_name" => "test1", "theme" => "1", "user_num" => "2", "startDateTime" => "", "endDateTime" => "", "showDescription" => "true", "x_token" => x_token})
    assert Xee.TokenServer.has?(x_token)
    xid = Xee.TokenServer.get(x_token)
    assert Xee.ExperimentServer.has?(xid)
  end
end
