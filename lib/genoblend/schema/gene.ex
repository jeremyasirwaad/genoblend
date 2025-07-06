defmodule Genoblend.Schema.Gene do
  alias Genoblend.Schema.User
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
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
    timestamps()
  end

  def changeset(gene, attrs) do
    gene
    |> cast(attrs, [:id, :name, :x_coordinate, :y_coordinate, :traits, :description, :color, :dead_at, :is_alive, :user_id])
    |> validate_required([:id, :name, :x_coordinate, :y_coordinate, :traits, :description, :color, :is_alive, :user_id])
  end
end
