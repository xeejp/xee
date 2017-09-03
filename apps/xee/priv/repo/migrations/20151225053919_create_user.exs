defmodule Xee.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :name, :string, null: false;
      add :crypted_password, :string, null: false;

      timestamps()
    end

    # add unique constraints to user.name
    create unique_index(:user, [:name])
  end
end
