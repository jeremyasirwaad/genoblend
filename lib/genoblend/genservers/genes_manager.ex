defmodule Genoblend.Genservers.GenesManager do
  use GenServer
  require Logger
  alias Genoblend.Genservers.GenepoolManager
  alias Genoblend.NearestPointFinder

  # Interval in milliseconds between movement pings
  @movement_interval 1_000

  @ets_table :gene_states

  def start_link(gene) do
    # Use a unique name for each gene process
    GenServer.start_link(__MODULE__, gene, name: {:via, Registry, {Genoblend.GeneRegistry, gene.id}})
  end

  def gene_info(pid) do
    state = GenServer.call(pid, :gene_info)
    {:ok, state}
  end

  def start_inital_genes(genes) do
    # Start all genes in parallel using Task.async_stream
    genes
    |> Task.async_stream(
      fn gene ->
        case start_link(gene) do
          {:ok, pid} ->
            Logger.info("Successfully started gene #{gene.name} with PID #{inspect(pid)}")
            GenepoolManager.add_gene(gene.id, pid)
            {:ok, gene.id, pid}

          {:error, reason} ->
            Logger.error("Failed to start gene #{gene.name}: #{inspect(reason)}")
            {:error, gene.id, reason}
        end
      end,
      max_concurrency: System.schedulers_online(),
      timeout: 5000
    )
    |> Enum.to_list()
    |> Enum.map(fn {:ok, result} -> result end)
  end

  def kill_gene(gene_id) do
    Logger.info("Killing gene #{gene_id}")
    GenServer.cast({:via, Registry, {Genoblend.GeneRegistry, gene_id}}, :shutdown)
  end

  def init(gene) do
    initial_gene_state = %{
      name: gene.name,
      id: gene.id,
      x_coordinate: gene.x_coordinate,
      y_coordinate: gene.y_coordinate,
      traits: gene.traits,
      description: gene.description,
      color: gene.color,
      dead_at: gene.dead_at,
      is_alive: gene.is_alive,
      user_id: gene.user_id,
      movement_timer: nil,
      created_at: Map.get(gene, :created_at, DateTime.utc_now())
    }

    # Start recurring movement timer
    movement_timer = schedule_movement()

    new_state = Map.put(initial_gene_state, :movement_timer, movement_timer)

    # Persist initial state in ETS so others can see it without GenServer.call
    :ets.insert(@ets_table, {gene.id, new_state})

    {:ok, new_state}
  end

  def handle_call(:gene_info, _from, state) do
    {:reply, state, state}
  end

  defp schedule_movement do
    Process.send_after(self(), :movement_tick, @movement_interval)
  end

  def handle_info(:movement_tick, state) do
    # Determine new coordinates or fusion action
    outcome = move_gene_towards_closest_gene(state)

    Logger.info("Outcome: #{inspect(outcome.distance)}")

    updated_state =
      case outcome do
        %{nearest_gene: nearest_gene, distance: +0.0} ->
          GenepoolManager.declare_fusion(state.id, nearest_gene.id)
          state


        %{next_coordinate: next_coordinate} ->

          Logger.info("Moving gene #{state.name} to #{next_coordinate.x_coordinate}, #{next_coordinate.y_coordinate}")

          %{state | x_coordinate: next_coordinate.x_coordinate, y_coordinate: next_coordinate.y_coordinate}
      end

    # Always reschedule the next tick
    new_timer = schedule_movement()
    new_state_with_timer = %{updated_state | movement_timer: new_timer}

    # Update ETS with the new state so other genes can query positions
    :ets.insert(@ets_table, {state.id, new_state_with_timer})

    {:noreply, new_state_with_timer}
    # {:noreply, state}

  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def handle_cast(:shutdown, state) do
    # Remove from ETS
    :ets.delete(@ets_table, state.id)
    Logger.info("Gene #{state.id} has been killed")
    {:stop, :normal, state}
  end

  #########################################################
  # Movement logic
  #########################################################

  def move_gene_towards_closest_gene(state) do
    all_genes = GenepoolManager.get_all_genes()

    # If there are no other genes, stay in place
    if Enum.empty?(all_genes) do
      %{nearest_gene: state, distance: 0, next_coordinate: %{x_coordinate: state.x_coordinate, y_coordinate: state.y_coordinate}}
    else
      NearestPointFinder.find_nearest_and_next_move(state, all_genes)
    end
  end
end
