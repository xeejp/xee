defmodule Xee.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :name, :string
      add :crypted_password, :string

      timestamps
    end

  end
end
