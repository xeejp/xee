defmodule Xee.SessionTest do
  use XeeWeb.ConnCase
  use Xee.SessionTestHelper

  alias Xee.User
  alias Xee.Session

  @correct_attrs %{name: "correct_name", password: "correct_password"}
  @incorrect_attrs %{name: "incorrect_name", password: "incorrect_pasword"}

  setup do
    changeset = User.changeset(%User{}, @correct_attrs)
    User.create(changeset, Xee.Repo)
    :ok
  end

  test "login as correct user" do
    session = %{"name" => @correct_attrs[:name], "password" => @correct_attrs[:password]}
    {status, _user} = Session.login(session, Xee.Repo);
    assert status == :ok
  end

  test "login as incorrect user" do
    session = %{"name" => @incorrect_attrs[:name], "password" => @incorrect_attrs[:password]}
    status = Session.login(session, Xee.Repo);
    assert status == :error
  end

  test "check whether loggedin or not" do
    conn = build_conn
    session = %{"name" => @correct_attrs[:name], "password" => @correct_attrs[:password]}
    {_status, user} = Session.login(session, Xee.Repo);

    conn = build_conn
            |> with_session_and_flash
            |> Plug.Conn.put_session(:current_user, user.id)
    assert Session.logged_in?(conn)

    conn = build_conn
            |> with_session_and_flash
            |> Plug.Conn.delete_session(:current_user)
    refute Session.logged_in?(conn)
  end

  test "check current user" do
    conn = build_conn
    session = %{"name" => @correct_attrs[:name], "password" => @correct_attrs[:password]}
    {_status, user} = Session.login(session, Xee.Repo);

    conn = build_conn
            |> with_session_and_flash
            |> Plug.Conn.put_session(:current_user, user.id)
    assert Session.current_user(conn).name == @correct_attrs[:name]
    refute Session.current_user(conn).name == @incorrect_attrs[:name]

    conn = build_conn
            |> with_session_and_flash
            |> Plug.Conn.delete_session(:current_user)
    refute Session.logged_in?(conn)
  end
end
