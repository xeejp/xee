defmodule Xee.User do
  use Xee.Web, :model

  schema "user" do
    field :name, :string
    field :crypted_password, :string

    timestamps
  end

  @required_fields ~w(name crypted_password)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
