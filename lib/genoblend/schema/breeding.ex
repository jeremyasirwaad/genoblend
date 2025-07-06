defmodule Genoblend.Schema.Breeding do
  alias Genoblend.Schema.Gene
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "breedings" do
    belongs_to :parent1, Gene
    belongs_to :parent2, Gene
    belongs_to :child, Gene
    field :notes, :string

    timestamps()
  end

  def changeset(breeding, attrs) do
    breeding
    |> cast(attrs, [:id, :parent1_id, :parent2_id, :child_id, :notes])
    |> validate_required([:id, :parent1_id, :parent2_id])
    |> foreign_key_constraint(:parent1_id)
    |> foreign_key_constraint(:parent2_id)
    |> foreign_key_constraint(:child_id)
  end
end
