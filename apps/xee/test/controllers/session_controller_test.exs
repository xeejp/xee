defmodule XeeWeb.SessionControllerTest do
  use XeeWeb.ConnCase
  use ExUnit.Case, async: false
  use XeeWeb.SessionTestHelper, controller: XeeWeb.SessionController

  alias Xee.User
  alias Xee.Session

  @valid_user_attrs %{name: "valid_user_name", password: "valid_user_password"}
  @invalid_user_attrs %{name: "invalid_user_name", password: "invalid_user_password"}

  setup do
    changeset = User.changeset(%User{}, @valid_user_attrs);
    User.create(changeset, Xee.Repo)
    :ok
  end

  test "GET /login" do
    conn = get build_conn(), "/login"
    assert conn.status == 200
  end

  test "POST /login with valid user information" do
    session = %{"name" => @valid_user_attrs[:name], "password" => @valid_user_attrs[:password]}
    conn = build_conn()
            |> with_session_and_flash
            |> action(:create, %{"session" => session})

    assert Session.logged_in?(conn)
  end

  test "POST /login with invalid user information" do
    session = %{"name" => @invalid_user_attrs[:name], "password" => @invalid_user_attrs[:password]}
    conn = build_conn()
            |> with_session_and_flash
            |> action(:create, %{"session" => session})

    assert get_flash(conn, :info) =~ "Name or password is incorrect."
    refute Session.logged_in?(conn)
  end

  test "GET /logout in order to logout" do
    session = %{"name" => @valid_user_attrs[:name], "password" => @valid_user_attrs[:password]}
    {_status, user} = Session.login(session, Xee.Repo);
    conn = build_conn()
            |> with_session_and_flash
            |> Plug.Conn.put_session(:current_user, user.id)
    assert Session.logged_in?(conn)

    conn = conn
            |> with_session_and_flash
            |> action(:delete)

    refute Session.logged_in?(conn)
  end
end

