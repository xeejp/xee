defmodule Xee.RegistrationControllerTest do
  use Xee.ConnCase
  use ExUnit.Case, async: false
  use Xee.SessionTestHelper, controller: Xee.RegistrationController

  alias Xee.User
  alias Xee.Session

  @new_user_attrs %{name: "new_user_name", password: "new_user_password"}
  @existed_user_attrs %{name: "existed_user_name", password: "existed_user_password"}
  @invalid_user_attrs1 %{name: "user_name", password: "p"}
  @invalid_user_attrs2 %{name: "", password: "user_password"}

  setup do
    changeset = User.changeset(%User{}, @existed_user_attrs);
    User.create(changeset, Xee.Repo)
    :ok
  end

  test "GET /register" do
    conn = get conn(), "/register"
    refute html_response(conn, 200) =~ "Error!"
  end

  test "POST /register with new user information" do
    conn = conn()
            |> with_session_and_flash
            |> action(:create, %{"user" => @new_user_attrs})

    refute get_flash(conn, :info) =~ "Failed to registration."
    assert Session.logged_in?(conn)
  end

  test "POST /register with existed user information" do
    conn = conn()
            |> with_session_and_flash
            |> action(:create,  %{"user" => @existed_user_attrs})

    assert get_flash(conn, :info) =~ "Failed to registration."
    refute Session.logged_in?(conn)
  end

  test "POST /register with invalid user information(User password is not long enough)" do
    conn = conn()
            |> with_session_and_flash
            |> action(:create,  %{"user" => @invalid_user_attrs1})

    assert get_flash(conn, :info) =~ "Failed to registration."
    refute Session.logged_in?(conn)
  end

  test "POST /register with invalid user information(User name is not long enough)" do
    conn = conn()
            |> with_session_and_flash
            |> action(:create,  %{"user" => @invalid_user_attrs2})

    assert get_flash(conn, :info) =~ "Failed to registration."
    refute Session.logged_in?(conn)
  end
end

