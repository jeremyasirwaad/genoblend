defmodule Genoblend.Schema.User do
  alias Genoblend.Schema.Gene
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :name, :string
    field :ip, :string
    field :location, :string
    has_many :genes, Gene

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :ip, :location])
    |> validate_required([:name, :ip, :location])
  end
end
