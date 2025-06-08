defmodule Genoblend.Schema.Breeding do
  alias Genoblend.Schema.Gene
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "breedings" do
    belongs_to :parent1, Gene
    belongs_to :parent2, Gene
    has_one :child, Gene
    field :notes, :string

    timestamps()
  end
end
