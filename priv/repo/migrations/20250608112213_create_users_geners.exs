defmodule Genoblend.Repo.Migrations.CreateUsersGeners do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :ip, :string, null: true
      add :location, :string, null: true
    end

    create table(:genes) do
      add :name, :string, null: false
      add :x_coordinate, :integer, null: false
      add :y_coordinate, :integer, null: false
      add :traits, {:array, :string}, null: false
      add :user_id, references(:users, on_delete: :restrict), null: false
    end
  end
end
