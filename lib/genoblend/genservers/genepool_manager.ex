defmodule Genoblend.Genservers.GenepoolManager do
  alias Genoblend.Genservers.GenesManager
  alias Genoblend.Const
  use GenServer
  require Logger

  @ets_table :gene_states

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_opts) do
    Process.flag(:trap_exit, true)
    Logger.info("Gene-pool manager started")

    # Create or clear ETS table to hold gene states
    case :ets.whereis(@ets_table) do
      :undefined -> :ets.new(@ets_table, [:named_table, :public, :set])
      tid when is_reference(tid) -> :ets.delete_all_objects(@ets_table)
    end

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

  @spec get_all_genes() :: list(map())
  def get_all_genes() do
    :ets.tab2list(@ets_table)
    |> Enum.map(fn {_id, state} -> state end)
  end

  def kill_gene(gene_id) do
    GenesManager.kill_gene(gene_id)
    Registry.unregister(Genoblend.GeneRegistry, gene_id)

  end

  def declare_fusion(gene_1_id, gene_2_id) do
    kill_gene(gene_1_id)
    kill_gene(gene_2_id)
    Logger.info("Declared fusion between genes #{gene_1_id} and #{gene_2_id}")
  end
end
