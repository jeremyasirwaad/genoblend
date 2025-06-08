defmodule Genoblend.Users do
  alias Genoblend.Schema.User
  alias Genoblend.Repo

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_all_genes(user_id) do
    Repo.get!(User, user_id)
    |> Repo.preload(:genes)
  end
end
