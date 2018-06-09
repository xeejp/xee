defmodule Xee.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Xee.User

  schema "user" do
    field :name, :string
    field :crypted_password, :string
    field :password, :string, virtual: true

    timestamps()
  end

  def changeset(%User{} = user, attrs \\ :empty) do
    user
    |> cast(attrs, [:name, :crypted_password, :password])
    |> validate_required([:name, :password])
    |> validate_length(:name, min: 1)
    |> validate_length(:password, min: 5)
    |> update_change(:name, &String.downcase/1)
    |> unique_constraint(:name)
  end

  @doc """
  Create a new record of user table.
  """
  def create(changeset, repo) do
    changeset
    |> put_change(:crypted_password, hashed_password(changeset.params["password"]))
    |> repo.insert()
  end

  @doc """
  Hashing password
  """
  defp hashed_password(password) do
    Comeonin.Bcrypt.hashpwsalt(password)
  end
end
