defmodule Genoblend.Schema.Gene do
  alias Genoblend.Schema.{User, Breeding}
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "genes" do
    field :name, :string
    field :x_coordinate, :float
    field :y_coordinate, :float
    field :traits, {:array, :string}
    field :description, :string
    field :color, :string
    field :dead_at, :utc_datetime
    field :is_alive, :boolean, default: true

    belongs_to :user, User
    belongs_to :breeding, Breeding
    timestamps()
  end

  def changeset(gene, attrs) do
    gene
    |> cast(attrs, [:name, :x_coordinate, :y_coordinate, :traits, :description, :color, :dead_at, :is_alive, :user_id])
    |> validate_required([:name, :x_coordinate, :y_coordinate, :traits, :description, :color, :is_alive])
  end
end
