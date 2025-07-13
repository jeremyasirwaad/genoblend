defmodule Genoblend.Genservers.GenepoolManager do
  alias Genoblend.Genservers.{GenesManager, GenestatsStatsManager, GeneeventBroadcaster}
  alias Genoblend.Const
  alias Genoblend.Genes
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
    Genes.delete_all_genes()
    initial_genes = Const.get_default_genes()

    # Save initial genes to database before starting them
    Enum.each(initial_genes, fn gene_data ->
      case Genes.create_gene(gene_data) do
        {:ok, gene} ->
          Logger.info("Successfully saved initial gene #{gene_data.name} to database")
          # Broadcast gene created event for initial genes
          GenestatsStatsManager.broadcast_on_gene_created(gene.id)
          Logger.info("Broadcasting gene birth for initial gene: #{gene_data.name}")
          try do
            GeneeventBroadcaster.broadcast_gene_birth(gene_data.name)
          rescue
            error ->
              Logger.error("Failed to broadcast gene birth: #{inspect(error)}")
          end
        {:error, changeset} ->
          Logger.error("Failed to save initial gene #{gene_data.name} to database: #{inspect(changeset)}")
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
  Debug function to check database state
  """
  def debug_database_state() do
    gene_count = Genes.count_genes()
    gene_ids = Genes.get_all_gene_ids()
    Logger.info("Database contains #{gene_count} genes")
    Logger.info("Gene IDs in database: #{inspect(gene_ids)}")

    ets_genes = :ets.tab2list(@ets_table) |> Enum.map(fn {id, _state} -> id end)
    Logger.info("ETS contains #{length(ets_genes)} genes")
    Logger.info("Gene IDs in ETS: #{inspect(ets_genes)}")

    missing_in_db = ets_genes -- gene_ids
    if length(missing_in_db) > 0 do
      Logger.warning("Genes in ETS but not in database: #{inspect(missing_in_db)}")
    end

    {gene_count, gene_ids, ets_genes}
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
    # Update database first
    case Genes.kill_gene(gene_id) do
      {:ok, _gene} ->
        Logger.info("Successfully marked gene #{gene_id} as dead in database")
        # Broadcast gene killed event
        GenestatsStatsManager.broadcast_on_gene_killed(gene_id)
        
        # Get gene name from ETS for event broadcasting
        case :ets.lookup(@ets_table, gene_id) do
          [{^gene_id, gene_state}] ->
            gene_name = Map.get(gene_state, :name, "Unknown Gene")
            age_seconds = calculate_gene_age(gene_state)
            GeneeventBroadcaster.broadcast_gene_death(gene_name, age_seconds)
          [] ->
            GeneeventBroadcaster.broadcast_gene_death("Unknown Gene")
        end
      {:error, reason} ->
        Logger.error("Failed to mark gene #{gene_id} as dead in database: #{inspect(reason)}")
    end

    # Kill the gene process
    GenesManager.kill_gene(gene_id)
    Registry.unregister(Genoblend.GeneRegistry, gene_id)
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
    with {:ok, parent_1_state, parent_2_state} <- get_parents(parent_1_id, parent_2_id),
         {:ok, character_data} <- create_new_gene(parent_1_state, parent_2_state) do

      # Save child gene to database first
      case save_child_gene_to_database(parent_1_id, parent_2_id, character_data) do
        {:ok, _child_gene} ->
          # Start the gene process after saving to database
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
        {:error, reason} ->
          Logger.error("Failed to save child gene to database: #{inspect(reason)}")
          {:error, reason}
      end
    else
      error ->
        Logger.error("Failed to create new gene from parents: #{inspect(error)}")
        error
    end
  end

  def create_new_gene_from_parent_data(parent_1_id, parent_2_id, parent_1_state, parent_2_state) do
    case create_new_gene(parent_1_state, parent_2_state) do
      {:ok, character_data} ->
        # Save child gene to database first
        case save_child_gene_to_database(parent_1_id, parent_2_id, character_data) do
          {:ok, _child_gene} ->
            # Start the gene process after saving to database
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
          {:error, reason} ->
            Logger.error("Failed to save child gene to database: #{inspect(reason)}")
            {:error, reason}
        end
      {:error, reason} ->
        Logger.error("Failed to create new gene from parent data: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp save_child_gene_to_database(parent_1_id, parent_2_id, character_data) do
    # Convert character_data to gene attributes format
    gene_attrs = %{
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

    justification = Map.get(character_data, :justification, "Generated from AI breeding")

    # Ensure parent genes exist in database before creating child
    ensure_parent_genes_in_db(parent_1_id, parent_2_id)

    case Genes.create_child_gene_with_breeding(parent_1_id, parent_2_id, gene_attrs, justification) do
      {:ok, child_gene} ->
        Logger.info("Successfully saved child gene #{child_gene.name} with breeding record")
        {:ok, child_gene}
      {:error, reason} ->
        Logger.error("Failed to save child gene with breeding: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp ensure_parent_genes_in_db(parent_1_id, parent_2_id) do
    ensure_gene_in_db(parent_1_id)
    ensure_gene_in_db(parent_2_id)
  end

  defp ensure_gene_in_db(gene_id) do
    # Check if gene already exists in database
    case Genes.get_gene(gene_id) do
      nil ->
        # Gene doesn't exist in database, get it from ETS and save it
        case :ets.lookup(@ets_table, gene_id) do
          [{^gene_id, gene_state}] ->
            gene_attrs = %{
              id: gene_state.id,
              name: gene_state.name,
              x_coordinate: gene_state.x_coordinate,
              y_coordinate: gene_state.y_coordinate,
              traits: gene_state.traits,
              description: gene_state.description,
              color: gene_state.color,
              dead_at: gene_state.dead_at,
              is_alive: gene_state.is_alive,
              user_id: gene_state.user_id
            }

            case Genes.get_or_create_gene(gene_attrs) do
              {:ok, _gene} ->
                Logger.info("Successfully saved parent gene to database")
              {:error, reason} ->
                Logger.error("Failed to save parent gene to database: #{inspect(reason)}")
            end
          [] ->
            Logger.error("Parent gene #{gene_id} not found in ETS table")
        end
      _existing_gene ->
        Logger.info("Gene #{gene_id} already exists in database")
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
    name: #{Map.get(parent_1_state, :name, "Unknown")}
    traits: #{format_traits(Map.get(parent_1_state, :traits, []))}
    description: #{Map.get(parent_1_state, :description, "")}
    color: #{Map.get(parent_1_state, :color, "#000000")}

    ## Parent 2
    name: #{Map.get(parent_2_state, :name, "Unknown")}
    traits: #{format_traits(Map.get(parent_2_state, :traits, []))}
    description: #{Map.get(parent_2_state, :description, "")}
    color: #{Map.get(parent_2_state, :color, "#000000")}
    ---
    """

    generate_new_gene_with_retry(system_prompt, user_prompt, 3)
  end

  defp generate_new_gene_with_retry(system_prompt, user_prompt, retries_left) when retries_left > 0 do
    model_id = "gemini-2.0-flash"

    case Genoblend.GenoAi.Gemini.generate_content(model_id, system_prompt, user_prompt) do
      {:ok, response} ->
        case parse_character_response(response) do
                      {:ok, character_data} ->
              Logger.info("Successfully generated new character: #{inspect(character_data)}")

              # Add game-specific properties to the character
              enhanced_character_data = character_data
                |> Map.put(:id, Ecto.UUID.generate())
                |> Map.put(:x_coordinate, Enum.random(0..200))
                |> Map.put(:y_coordinate, Enum.random(0..200))
                |> Map.put(:dead_at, nil)
                |> Map.put(:is_alive, true)
                |> Map.put(:user_id, "8dadde5c-1ce1-4d63-94cd-eb664a673927")

              {:ok, enhanced_character_data}
          {:error, parse_error} ->
            Logger.warning("Failed to parse character response, retries left: #{retries_left - 1}. Error: #{inspect(parse_error)}")
            generate_new_gene_with_retry(system_prompt, user_prompt, retries_left - 1)
        end
      {:error, api_error} ->
        Logger.error("Failed to generate character from API: #{inspect(api_error)}")
        {:error, {:api_error, api_error}}
    end
  end

  defp generate_new_gene_with_retry(_system_prompt, _user_prompt, 0) do
    Logger.error("Failed to generate new character after all retries")
    {:error, :max_retries_exceeded}
  end

  defp parse_character_response(response) do
    try do
      # Extract character block
      character_match = Regex.run(~r/<character>\s*(.*?)\s*<\/character>/s, response, capture: :all_but_first)
      justification_match = Regex.run(~r/<justification>\s*(.*?)\s*<\/justification>/s, response, capture: :all_but_first)

      case character_match do
        [character_content] ->
          character_data = parse_character_content(character_content)
          justification = case justification_match do
            [justification_content] -> String.trim(justification_content)
            _ -> ""
          end

          {:ok, Map.put(character_data, :justification, justification)}
        _ ->
          {:error, :character_block_not_found}
      end
    catch
      error -> {:error, {:parse_exception, error}}
    end
  end

  defp parse_character_content(content) do
    lines = String.split(content, "\n") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))

    Enum.reduce(lines, %{}, fn line, acc ->
      case String.split(line, ":", parts: 2) do
        [key, value] ->
          key = String.trim(key) |> String.downcase() |> String.to_atom()
          value = String.trim(value)

          case key do
            :traits ->
              traits = String.split(value, ",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))
              Map.put(acc, :traits, traits)
            _ ->
              Map.put(acc, key, value)
          end
        _ ->
          acc
      end
    end)
  end

  defp format_traits(traits) when is_list(traits), do: Enum.join(traits, ", ")
  defp format_traits(traits) when is_binary(traits), do: traits
  defp format_traits(_), do: ""

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
end
