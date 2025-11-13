defmodule Genoblend.Genservers.GenepoolManager do
  alias Genoblend.Genservers.{GenesManager, GenestatsStatsManager, GeneeventBroadcaster}
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
      _tid -> :ets.delete_all_objects(@ets_table)
    end

        Registry.start_link(keys: :unique, name: Genoblend.GeneRegistry)
    start_inital_genes()

    {:ok, %{genepool_started_at: DateTime.utc_now()}}
  end

  def start_inital_genes() do
    initial_genes = Const.get_default_genes()

    # Start initial genes and store them in ETS
    Enum.each(initial_genes, fn gene_data ->
      Logger.info("Starting initial gene: #{gene_data.name}")
      # Broadcast gene created event for initial genes
      GenestatsStatsManager.broadcast_on_gene_created(gene_data.id)
      Logger.info("Broadcasting gene birth for initial gene: #{gene_data.name}")
      try do
        GeneeventBroadcaster.broadcast_gene_birth(gene_data.name)
      rescue
        error ->
          Logger.error("Failed to broadcast gene birth: #{inspect(error)}")
      end
    end)

    GenesManager.start_inital_genes(initial_genes)

    # Broadcast environment started event with delay to ensure broadcaster is ready
    Process.send_after(self(), :broadcast_environment_started, 1000)
  end

  def add_gene(gene_id, pid) do
    Registry.register(Genoblend.GeneRegistry, gene_id, pid)
  end

  @doc """
  Debug function to check ETS state
  """
  def debug_ets_state() do
    ets_genes = :ets.tab2list(@ets_table)
    gene_count = length(ets_genes)
    gene_ids = Enum.map(ets_genes, fn {id, _state} -> id end)

    Logger.info("ETS contains #{gene_count} genes")
    Logger.info("Gene IDs in ETS: #{inspect(gene_ids)}")

    alive_count = Enum.count(ets_genes, fn {_id, state} -> Map.get(state, :is_alive, true) end)
    dead_count = gene_count - alive_count

    Logger.info("Alive genes: #{alive_count}, Dead genes: #{dead_count}")

    {gene_count, gene_ids}
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
    Logger.info("Killing gene #{gene_id}")

    # Get gene name from ETS for event broadcasting before killing
    case :ets.lookup(@ets_table, gene_id) do
      [{^gene_id, gene_state}] ->
        gene_name = Map.get(gene_state, :name, "Unknown Gene")
        age_seconds = calculate_gene_age(gene_state)

        # Update gene state in ETS to mark as dead
        updated_state = Map.put(gene_state, :is_alive, false)
        :ets.insert(@ets_table, {gene_id, updated_state})

        # Broadcast gene killed event
        GenestatsStatsManager.broadcast_on_gene_killed(gene_id)
        GeneeventBroadcaster.broadcast_gene_death(gene_name, age_seconds)
      [] ->
        Logger.warning("Gene #{gene_id} not found in ETS during kill")
        GeneeventBroadcaster.broadcast_gene_death("Unknown Gene")
    end

    # Kill the gene process
    GenesManager.kill_gene(gene_id)
    Registry.unregister(Genoblend.GeneRegistry, gene_id)

    # Check alive gene count and replenish if needed
    check_and_replenish_genes()
  end

  def declare_fusion(gene_1_id, gene_2_id) do
    # Get parent data before killing them to prevent race conditions
    case get_parents(gene_1_id, gene_2_id) do
      {:ok, parent_1_state, parent_2_state} ->
        # Kill parent genes immediately to prevent other fusions
        kill_gene(gene_1_id)
        kill_gene(gene_2_id)

        # Create new gene using preserved parent data
        case create_new_gene_from_parent_data(gene_1_id, gene_2_id, parent_1_state, parent_2_state) do
          {:ok, new_gene_id, _pid} ->
            Logger.info("Declared fusion between genes #{gene_1_id} and #{gene_2_id}, created new gene #{new_gene_id}")
            # Broadcast fusion declared event
            GenestatsStatsManager.broadcast_on_fusion_declared(gene_1_id, gene_2_id, new_gene_id)
            
            # Get names for fusion event broadcasting (happens first)
            parent1_name = Map.get(parent_1_state, :name, "Unknown")
            parent2_name = Map.get(parent_2_state, :name, "Unknown")
            
            # Get child name from ETS table
            child_name = case :ets.lookup(@ets_table, new_gene_id) do
              [{^new_gene_id, child_state}] -> Map.get(child_state, :name, "Unknown Child")
              [] -> "Unknown Child"
            end
            
            # First broadcast fusion, then birth will be handled in gene creation
            GeneeventBroadcaster.broadcast_fusion_declared(parent1_name, parent2_name, child_name)
            {:ok, new_gene_id}
          {:error, reason} ->
            Logger.error("Failed to create offspring for fusion between #{gene_1_id} and #{gene_2_id}: #{inspect(reason)}")
            {:error, reason}
        end
      {:error, reason} ->
        Logger.error("Failed to get parent genes for fusion between #{gene_1_id} and #{gene_2_id}: #{inspect(reason)}")
        {:error, reason}
    end
  end


  def create_new_gene_from_parents(parent_1_id, parent_2_id) do
    case get_parents(parent_1_id, parent_2_id) do
      {:ok, parent_1_state, parent_2_state} ->
        {:ok, character_data} = create_new_gene(parent_1_state, parent_2_state)

        # Start the gene process
        case start_new_gene(character_data) do
          {:ok, gene_id, pid} ->
            Logger.info("Successfully created and started new gene from parents #{parent_1_id} and #{parent_2_id}")
            # Broadcast gene created event
            GenestatsStatsManager.broadcast_on_gene_created(gene_id)

            # Broadcast gene birth event with parent names
            parent1_name = Map.get(parent_1_state, :name, "Unknown")
            parent2_name = Map.get(parent_2_state, :name, "Unknown")
            child_name = Map.get(character_data, :name, "Unknown Child")
            GeneeventBroadcaster.broadcast_gene_birth(child_name, parent1_name, parent2_name)

            {:ok, gene_id, pid}
          {:error, reason} ->
            Logger.error("Failed to start new gene: #{inspect(reason)}")
            {:error, reason}
        end
      error ->
        Logger.error("Failed to create new gene from parents: #{inspect(error)}")
        error
    end
  end

  def create_new_gene_from_parent_data(parent_1_id, parent_2_id, parent_1_state, parent_2_state) do
    {:ok, character_data} = create_new_gene(parent_1_state, parent_2_state)

    # Start the gene process
    case start_new_gene(character_data) do
      {:ok, gene_id, pid} ->
        Logger.info("Successfully created and started new gene from parent data #{parent_1_id} and #{parent_2_id}")
        # Broadcast gene created event
        GenestatsStatsManager.broadcast_on_gene_created(gene_id)

        # Broadcast gene birth event with parent names
        parent1_name = Map.get(parent_1_state, :name, "Unknown")
        parent2_name = Map.get(parent_2_state, :name, "Unknown")
        child_name = Map.get(character_data, :name, "Unknown Child")
        GeneeventBroadcaster.broadcast_gene_birth(child_name, parent1_name, parent2_name)

        {:ok, gene_id, pid}
      {:error, reason} ->
        Logger.error("Failed to start new gene: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp start_new_gene(character_data) do
    # Convert character data to the format expected by GenesManager
    gene_data = %{
      id: character_data.id,
      name: character_data.name,
      x_coordinate: character_data.x_coordinate,
      y_coordinate: character_data.y_coordinate,
      traits: character_data.traits,
      description: character_data.description,
      color: character_data.color,
      dead_at: character_data.dead_at,
      is_alive: character_data.is_alive,
      user_id: character_data.user_id
    }

    case GenesManager.start_link(gene_data) do
      {:ok, pid} ->
        Logger.info("Successfully started new gene #{gene_data.name} with PID #{inspect(pid)}")
        add_gene(gene_data.id, pid)
        {:ok, gene_data.id, pid}
      {:error, reason} ->
        Logger.error("Failed to start new gene #{gene_data.name}: #{inspect(reason)}")
        {:error, reason}
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
    # Randomly select a gene from the predefined gene pool
    gene_pool = Const.get_gene_pool()
    selected_gene = Enum.random(gene_pool)

    parent_1_name = Map.get(parent_1_state, :name, "Unknown")
    parent_2_name = Map.get(parent_2_state, :name, "Unknown")

    Logger.info("Creating new gene from parents #{parent_1_name} and #{parent_2_name}")
    Logger.info("Randomly selected gene: #{selected_gene.name}")

    # Add game-specific properties to the character
    enhanced_character_data = selected_gene
      |> Map.put(:id, Ecto.UUID.generate())
      |> Map.put(:x_coordinate, Enum.random(0..200))
      |> Map.put(:y_coordinate, Enum.random(0..200))
      |> Map.put(:dead_at, nil)
      |> Map.put(:is_alive, true)
      |> Map.put(:user_id, "8dadde5c-1ce1-4d63-94cd-eb664a673927")
      |> Map.put(:justification, "Randomly generated offspring from gene pool")

    {:ok, enhanced_character_data}
  end

  defp calculate_gene_age(gene_state) do
    case Map.get(gene_state, :created_at) do
      nil -> nil
      created_at -> 
        now = DateTime.utc_now()
        DateTime.diff(now, created_at, :second)
    end
  end

  def handle_info(:broadcast_environment_started, state) do
    Logger.info("Broadcasting environment started event")
    GeneeventBroadcaster.broadcast_environment_started()
    {:noreply, state}
  end

  # Counts alive genes in ETS
  defp count_alive_genes() do
    :ets.tab2list(@ets_table)
    |> Enum.count(fn {_id, state} -> Map.get(state, :is_alive, true) end)
  end

  # Checks if alive gene count is below threshold and replenishes if needed
  defp check_and_replenish_genes() do
    alive_count = count_alive_genes()
    Logger.info("Current alive gene count: #{alive_count}")

    if alive_count < 10 do
      Logger.info("Gene count below 10! Replenishing with 100 new genes...")
      replenish_genes(100)
    end
  end

  # Creates and starts multiple new genes from the gene pool
  defp replenish_genes(count) do
    gene_pool = Const.get_gene_pool()

    Enum.each(1..count, fn _ ->
      # Randomly select a gene from the pool
      selected_gene = Enum.random(gene_pool)

      # Add game-specific properties
      gene_data = selected_gene
        |> Map.put(:id, Ecto.UUID.generate())
        |> Map.put(:x_coordinate, Enum.random(0..200))
        |> Map.put(:y_coordinate, Enum.random(0..200))
        |> Map.put(:dead_at, nil)
        |> Map.put(:is_alive, true)
        |> Map.put(:user_id, "8dadde5c-1ce1-4d63-94cd-eb664a673927")

      # Start the gene
      case start_new_gene(gene_data) do
        {:ok, gene_id, _pid} ->
          Logger.info("Replenished gene: #{selected_gene.name} (#{gene_id})")
          # Broadcast gene created and birth events
          GenestatsStatsManager.broadcast_on_gene_created(gene_id)
          GeneeventBroadcaster.broadcast_gene_birth(selected_gene.name)
        {:error, reason} ->
          Logger.error("Failed to replenish gene: #{inspect(reason)}")
      end
    end)

    Logger.info("Replenishment complete! Added #{count} new genes.")
  end
end
