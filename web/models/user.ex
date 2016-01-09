defmodule Xee.User do
  use Xee.Web, :model

  schema "user" do
    field :name, :string
    field :crypted_password, :string
    field :password, :string, virtual: true

    timestamps
  end

  @required_fields ~w(name password)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> update_change(:name, &String.downcase/1)
    |> unique_constraint(:name)
    |> validate_length(:password, min: 5)
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
