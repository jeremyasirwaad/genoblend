defmodule Genoblend.Repo.Migrations.UpdateGeners do
  use Ecto.Migration

  def change do
    alter table(:genes) do
      add :parent_id,
        references(:genes, on_delete: :nilify_all),
        null: true
      add :child_id,
        references(:genes, on_delete: :nilify_all),
        null: true
    end
  end
end
