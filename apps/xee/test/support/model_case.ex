defmodule Xee.ModelCase do
  @moduledoc """
  This module defines the test case to be used by
  model tests.

  You may define functions here to be used as helpers in
  your model tests. See `errors_on/2`'s definition as reference.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Xee.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 2]
      import Xee.ModelCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Xee.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Xee.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  Helper for returning list of errors in model when passed certain data.

  ## Examples

  Given a User model that has validation for the presence of a value for the
  `:name` field and validation that `:password` is "safe":

      iex> errors_on(%User{}, password: "password")
      [{:password, "is unsafe"}, {:name, "is blank"}]

  You would then write your assertion like:

      assert {:password, "is unsafe"} in errors_on(%User{}, password: "password")
  """
  def errors_on(struct, data) do
    struct.__struct__.changeset(struct, data)
    |> Ecto.Changeset.traverse_errors(&Xee.ErrorHelpers.translate_error/1)
    |> Enum.flat_map(fn {key, errors} -> for msg <- errors, do: {key, msg} end)
  end
end
