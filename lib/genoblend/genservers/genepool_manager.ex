defmodule Genoblend.Genservers.GenepoolManager do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_opts) do
    Logger.info("Gene-pool manager started")
    Registry.start_link(keys: :unique, name: Genoblend.GeneRegistry)
    {:ok, %{genepool_started_at: DateTime.utc_now()}}
  end

  def add_gene(gene_id, pid) do
    Registry.register(Genoblend.GeneRegistry, gene_id, pid)
  end

  def get_gene(gene_id) do
    case Registry.lookup(Genoblend.GeneRegistry, gene_id) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end
end
