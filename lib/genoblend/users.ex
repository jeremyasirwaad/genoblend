defmodule Genoblend.Users do
  alias Genoblend.Schema.User
  alias Genoblend.Repo

  def create_user(attrs) do
    attrs_with_id = Map.put_new(attrs, :id, Ecto.UUID.generate())

    %User{}
    |> User.changeset(attrs_with_id)
    |> Repo.insert()
  end

  def get_all_genes(user_id) do
    Repo.get!(User, user_id)
    |> Repo.preload(:genes)
  end
end
