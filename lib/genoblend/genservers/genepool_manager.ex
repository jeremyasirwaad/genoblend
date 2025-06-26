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


  def create_new_gene_from_parents(parent_1_id, parent_2_id) do
    with {:ok, parent_1_state, parent_2_state} <- get_parents(parent_1_id, parent_2_id) do

    end
  end

  def get_parents(parent_1_id, parent_2_id) do
    case {:ets.lookup(@ets_table, parent_1_id), :ets.lookup(@ets_table, parent_2_id)} do
      {[{^parent_1_id, parent_1_state}], [{^parent_2_id, parent_2_state}]} ->
        # Found both parents, now we can proceed with gene creation
        Logger.info("Found parent 1: #{inspect(parent_1_state)}")
        Logger.info("Found parent 2: #{inspect(parent_2_state)}")
        {:ok, parent_1_state, parent_2_state}

      {[], _} ->
        Logger.error("Parent 1 gene not found: #{parent_1_id}")
        {:error, :parent_1_not_found}

      {_, []} ->
        Logger.error("Parent 2 gene not found: #{parent_2_id}")
        {:error, :parent_2_not_found}
    end
  end

  def create_new_gene(parent_1_state, parent_2_state) do

    system_prompt = """
    You an expert in creating characters. Your task is to create a child character from the given parent characters' features.

    ## Instructions to create characters
    - A character will have a  list of `traits`, a `description` and a `color`.
    - Color represents the character.

    ## Instruction for creating a new character
    - The new character's traits list, description and the color should be of a derivative and fusion of the parents' features.

    ## Output format

    ```
    <character>
    name: <A new general name>
    traits: <comma separated values, max of 3>
    description: <description for the character in max 40 words>
    color: <hex code>
    </character>

    <justification>
    The justification of the fusion goes here. Justify only how the trait got derived.
    </justification>
    ```
    """

    user_prompt = """
    # Input

    ## Parent 1
    name: Bubbles McGillicuddy
    traits: Anger, Honest
    description: I am quick to anger when I see injustice, but I'm also brutally honest and always speak the truth. When I see something wrong, my honesty and anger combine into a fierce determination to speak up.
    color: #d04c56

    ## Parent 2
    name: Zigzag Thunderbolt
    traits: Brave, Curious, Optimistic
    description: I am fearless in the face of danger, always asking questions and exploring new things, and always see the bright side of life.
    color: #d693b2
    ---
    """

    {:ok, new_gene_id}
  end
end
