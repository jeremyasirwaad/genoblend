defmodule Genoblend.Genes do
  @moduledoc """
  The Genes context - handles database operations for genes and breeding records.
  """

  alias Genoblend.Schema.{Gene, Breeding}
  alias Genoblend.Repo
  import Ecto.Query

  @doc """
  Creates a new gene in the database.
  """
  def create_gene(attrs) do
    attrs_with_id = Map.put_new(attrs, :id, Ecto.UUID.generate())

    %Gene{}
    |> Gene.changeset(attrs_with_id)
    |> Repo.insert()
  end

  @doc """
  Creates a breeding record with parent genes.
  """
  def create_breeding(parent1_id, parent2_id, notes \\ nil) do
    breeding_attrs = %{
      id: Ecto.UUID.generate(),
      parent1_id: parent1_id,
      parent2_id: parent2_id,
      notes: notes
    }

    %Breeding{}
    |> Breeding.changeset(breeding_attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a child gene from parents and updates the breeding record.
  """
    def create_child_gene_with_breeding(parent1_id, parent2_id, child_attrs, notes \\ nil) do
    Repo.transaction(fn ->
      # First create the child gene
      case create_gene(child_attrs) do
        {:ok, child_gene} ->
          # Create the breeding record with all references
          breeding_attrs = %{
            parent1_id: parent1_id,
            parent2_id: parent2_id,
            child_id: child_gene.id,
            notes: notes
          }

          breeding_attrs_with_id = Map.put(breeding_attrs, :id, Ecto.UUID.generate())

          case %Breeding{} |> Breeding.changeset(breeding_attrs_with_id) |> Repo.insert() do
            {:ok, _breeding} ->
              child_gene
            {:error, changeset} ->
              Repo.rollback(changeset)
          end
        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Gets a gene by ID.
  """
  def get_gene(id) do
    Repo.get(Gene, id)
  end

  @doc """
  Gets all genes for a user.
  """
  def get_user_genes(user_id) do
    from(g in Gene, where: g.user_id == ^user_id and g.is_alive == true)
    |> Repo.all()
  end

  @doc """
  Updates a gene's alive status and dead_at timestamp.
  """
  def kill_gene(gene_id) do
    case get_gene(gene_id) do
      nil -> {:error, :not_found}
      gene ->
        gene
        |> Ecto.Changeset.change(%{is_alive: false, dead_at: DateTime.truncate(DateTime.utc_now(), :second)})
        |> Repo.update()
    end
  end

  @doc """
  Gets all alive genes.
  """
  def get_all_alive_genes() do
    from(g in Gene, where: g.is_alive == true)
    |> Repo.all()
  end

  @doc """
  Gets or creates a gene. If the gene already exists, returns it.
  If it doesn't exist, creates it.
  """
  def get_or_create_gene(attrs) do
    case get_gene(attrs.id) do
      nil ->
        create_gene(attrs)
      existing_gene ->
        {:ok, existing_gene}
    end
  end

  @doc """
  Gets all gene IDs currently in the database for debugging.
  """
  def get_all_gene_ids() do
    from(g in Gene, select: g.id)
    |> Repo.all()
  end

  @doc """
  Debug function to count genes in database.
  """
  def count_genes() do
    from(g in Gene, select: count(g.id))
    |> Repo.one()
  end

  @doc """
  Deletes all genes from the database.
  """
  def delete_all_genes() do
    Repo.delete_all(Gene)
    Repo.delete_all(Breeding)
  end
end
