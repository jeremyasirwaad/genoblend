defmodule Genoblend.Genservers.GenepoolManager do
  alias Genoblend.Genservers.GenesManager
  alias Genoblend.Const
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_opts) do
    Process.flag(:trap_exit, true)
    Logger.info("Gene-pool manager started")
    Registry.start_link(keys: :unique, name: Genoblend.GeneRegistry)
    start_inital_genes()
    {:ok, %{genepool_started_at: DateTime.utc_now()}}
  end

  @spec start_inital_genes() :: list()
  def start_inital_genes() do
    initial_genes = Const.get_default_genes()
    GenesManager.start_inital_genes(initial_genes)
  end

  def add_gene(gene_id, pid) do
    Registry.register(Genoblend.GeneRegistry, gene_id, pid)
  end

  @spec get_gene(any()) :: {:error, :not_found} | {:ok, pid()}
  def get_gene(gene_id) do
    with [{pid, _}] <- Registry.lookup(Genoblend.GeneRegistry, gene_id),
         {:ok, gene_info} <- GenesManager.gene_info(pid) do
      {:ok, gene_info}
    else
      _ -> {:error, :not_found}
    end
  end
end
