defmodule Genoblend.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :ip, :string
      add :location, :string

      timestamps()
    end

    create table(:genes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :x_coordinate, :float
      add :y_coordinate, :float
      add :traits, {:array, :string}
      add :description, :text
      add :color, :string
      add :dead_at, :utc_datetime
      add :is_alive, :boolean, default: true
      add :user_id, references(:users, type: :binary_id, on_delete: :nilify_all)

      timestamps()
    end

    create table(:breedings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :notes, :text

      timestamps()
    end

    alter table(:genes) do
      add :breeding_id, references(:breedings, type: :binary_id, on_delete: :nilify_all)
    end

    alter table(:breedings) do
      add :parent1_id, references(:genes, type: :binary_id, on_delete: :nilify_all)
      add :parent2_id, references(:genes, type: :binary_id, on_delete: :nilify_all)
      add :child_id, references(:genes, type: :binary_id, on_delete: :nilify_all)
    end

  end
end
