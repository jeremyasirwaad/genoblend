defmodule Genoblend.Genservers.GenestatsStatsManager do
  use GenServer
  require Logger
  alias Genoblend.Schema.{Gene, Breeding}
  alias Genoblend.Repo
  import Ecto.Query

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_opts) do
    Logger.info("Genestats broadcaster started")
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
    broadcast_stats_update("fusion_declared", %{
      parent1_id: parent1_id,
      parent2_id: parent2_id,
      child_id: child_id
    })
    {:noreply, state}
  end

  defp broadcast_stats_update(event_type, event_data) do
    stats_data = get_current_stats()

    Logger.warn("Broadcasting stats update to room:stats - event: #{event_type}")

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
      total_generations: get_total_generations_count(),
      environment_uptime: get_environment_uptime(),
      oldest_gene: get_oldest_gene()
    }
  end

  defp get_total_genes_count do
    from(g in Gene, select: count(g.id))
    |> Repo.one()
  end

  defp get_alive_genes_count do
    from(g in Gene, where: g.is_alive == true, select: count(g.id))
    |> Repo.one()
  end

  defp get_dead_genes_count do
    from(g in Gene, where: g.is_alive == false, select: count(g.id))
    |> Repo.one()
  end

  defp get_total_fusions_count do
    from(b in Breeding, select: count(b.id))
    |> Repo.one()
  end

  defp get_total_generations_count do
    # Calculate generation based on breeding depth
    # Generation 1: Initial genes (no parents)
    # Generation 2: Genes with parents but parents have no parents
    # Generation 3: Genes whose parents have parents, etc.

    max_generation_query = """
    WITH RECURSIVE generation_calc AS (
      -- Base case: genes with no parents (generation 1)
      SELECT g.id, 1 as generation
      FROM genes g
      LEFT JOIN breedings b ON g.id = b.child_id
      WHERE b.child_id IS NULL

      UNION ALL

      -- Recursive case: genes with parents
      SELECT g.id, MAX(gc.generation) + 1 as generation
      FROM genes g
      JOIN breedings b ON g.id = b.child_id
      JOIN generation_calc gc ON (gc.id = b.parent1_id OR gc.id = b.parent2_id)
      GROUP BY g.id
    )
    SELECT COALESCE(MAX(generation), 1) as max_gen FROM generation_calc
    """

    case Repo.query(max_generation_query) do
      {:ok, %{rows: [[max_gen]]}} when is_integer(max_gen) -> max_gen
      {:ok, %{rows: [[max_gen]]}} when is_binary(max_gen) -> String.to_integer(max_gen)
      _ -> 1
    end
  end

  defp get_environment_uptime do
    # Get system uptime in seconds
    {uptime_ms, _} = :erlang.statistics(:wall_clock)
    div(uptime_ms, 1000)
  end

  defp get_oldest_gene do
    case from(g in Gene,
      where: g.is_alive == true,
      order_by: [asc: g.inserted_at],
      limit: 1,
      select: %{name: g.name, age_seconds: fragment("EXTRACT(EPOCH FROM (NOW() - ?))", g.inserted_at)}
    ) |> Repo.one() do
      nil -> nil
      gene -> %{
        name: gene.name,
        age_seconds: gene.age_seconds |> Decimal.to_float() |> round()
      }
    end
  end
end
