defmodule Genoblend.Genservers.GenestatsStatsManager do
  use GenServer
  require Logger

  @ets_table :gene_states
  @stats_table :gene_stats

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_opts) do
    Logger.info("Genestats broadcaster started")

    # Create ETS table for tracking stats
    case :ets.whereis(@stats_table) do
      :undefined -> :ets.new(@stats_table, [:named_table, :public, :set])
      _tid -> :ok
    end

    # Initialize stats counters
    :ets.insert(@stats_table, {:total_fusions, 0})
    :ets.insert(@stats_table, {:environment_started_at, DateTime.utc_now()})

    {:ok, %{}}
  end

  def broadcast_on_gene_created(gene_id) do
    GenServer.cast(__MODULE__, {:gene_created, gene_id})
  end

  def broadcast_on_gene_killed(gene_id) do
    GenServer.cast(__MODULE__, {:gene_killed, gene_id})
  end

  def broadcast_on_fusion_declared(parent1_id, parent2_id, child_id) do
    GenServer.cast(__MODULE__, {:fusion_declared, parent1_id, parent2_id, child_id})
  end

  def handle_cast({:gene_created, gene_id}, state) do
    Logger.info("Broadcasting stats update for gene created: #{gene_id}")
    broadcast_stats_update("gene_created", %{gene_id: gene_id})
    {:noreply, state}
  end

  def handle_cast({:gene_killed, gene_id}, state) do
    Logger.info("Broadcasting stats update for gene killed: #{gene_id}")
    broadcast_stats_update("gene_killed", %{gene_id: gene_id})
    {:noreply, state}
  end

  def handle_cast({:fusion_declared, parent1_id, parent2_id, child_id}, state) do
    Logger.info("Broadcasting stats update for fusion: #{parent1_id} + #{parent2_id} -> #{child_id}")

    # Increment fusion counter
    :ets.update_counter(@stats_table, :total_fusions, 1)

    broadcast_stats_update("fusion_declared", %{
      parent1_id: parent1_id,
      parent2_id: parent2_id,
      child_id: child_id
    })
    {:noreply, state}
  end

  defp broadcast_stats_update(event_type, event_data) do
    stats_data = get_current_stats()

    Logger.warning("Broadcasting stats update to room:stats - event: #{event_type}")

    GenoblendWeb.Endpoint.broadcast("room:stats", "stats_update", %{
      event_type: event_type,
      event_data: event_data,
      stats: stats_data,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    })
  end

  defp get_current_stats do
    %{
      total_genes: get_total_genes_count(),
      total_fusions: get_total_fusions_count(),
      alive_genes: get_alive_genes_count(),
      dead_genes: get_dead_genes_count(),
      environment_uptime: get_environment_uptime(),
      oldest_gene: get_oldest_gene()
    }
  end

  defp get_total_genes_count do
    case :ets.whereis(@ets_table) do
      :undefined -> 0
      _tid ->
        :ets.info(@ets_table, :size) || 0
    end
  end

  defp get_alive_genes_count do
    case :ets.whereis(@ets_table) do
      :undefined -> 0
      _tid ->
        :ets.tab2list(@ets_table)
        |> Enum.count(fn {_id, state} -> Map.get(state, :is_alive, true) end)
    end
  end

  defp get_dead_genes_count do
    case :ets.whereis(@ets_table) do
      :undefined -> 0
      _tid ->
        :ets.tab2list(@ets_table)
        |> Enum.count(fn {_id, state} -> !Map.get(state, :is_alive, true) end)
    end
  end

  defp get_total_fusions_count do
    case :ets.lookup(@stats_table, :total_fusions) do
      [{:total_fusions, count}] -> count
      [] -> 0
    end
  end

  defp get_environment_uptime do
    # Calculate uptime from when environment started
    case :ets.lookup(@stats_table, :environment_started_at) do
      [{:environment_started_at, started_at}] ->
        DateTime.diff(DateTime.utc_now(), started_at, :second)
      [] ->
        # Fallback to system uptime
        {uptime_ms, _} = :erlang.statistics(:wall_clock)
        div(uptime_ms, 1000)
    end
  end

  defp get_oldest_gene do
    case :ets.whereis(@ets_table) do
      :undefined ->
        nil
      _tid ->
        :ets.tab2list(@ets_table)
        |> Enum.filter(fn {_id, state} -> Map.get(state, :is_alive, true) end)
        |> Enum.min_by(
          fn {_id, state} ->
            case Map.get(state, :created_at) do
              nil -> DateTime.utc_now()
              created_at -> created_at
            end
          end,
          DateTime,
          fn -> nil end
        )
        |> case do
          nil ->
            nil
          {_id, state} ->
            case Map.get(state, :created_at) do
              nil ->
                nil
              created_at ->
                %{
                  name: Map.get(state, :name, "Unknown"),
                  age_seconds: DateTime.diff(DateTime.utc_now(), created_at, :second)
                }
            end
        end
    end
  end
end
