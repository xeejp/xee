defmodule Xee.UserTest do
  use Xee.ModelCase

  alias Xee.User

  @valid_attrs %{name: "valid_name", password: "valid_password"}
  @valid_attrs2 %{name: "valid_name2", password: "valid_password2"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "create record with valid changeset" do
    changeset = User.changeset(%User{}, @valid_attrs)
    {status, _user} = User.create(changeset, Xee.Repo)
    assert status == :ok
  end

  test "create record with existed changeset" do
    changeset = User.changeset(%User{}, @valid_attrs)
    {status, _user} = User.create(changeset, Xee.Repo)
    assert status == :ok

    # same paramaters
    changeset = User.changeset(%User{}, @valid_attrs)
    {status, _user} = User.create(changeset, Xee.Repo)
    refute status == :ok
  end

  test "create record with other changeset" do
    changeset = User.changeset(%User{}, @valid_attrs)
    {status, _user} = User.create(changeset, Xee.Repo)
    assert status == :ok

    # different paramaters
    changeset = User.changeset(%User{}, @valid_attrs2)
    {status, _user} = User.create(changeset, Xee.Repo)
    assert status == :ok
  end
end
