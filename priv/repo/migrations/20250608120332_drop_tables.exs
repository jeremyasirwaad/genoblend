defmodule Genoblend.Repo.Migrations.DropTables do
  use Ecto.Migration

  def up do
    drop table(:genes)
    drop table(:users)
    # drop table(:breedings)
  end
end
