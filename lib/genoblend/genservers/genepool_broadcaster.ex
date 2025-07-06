defmodule Genoblend.Genservers.GenepoolBroadcaster do
  use GenServer
  require Logger

  @ets_table :gene_states
  @broadcast_interval 1000  # 1 second in milliseconds

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @doc """
  Manually trigger a broadcast for testing
  """
  def manual_broadcast do
    GenServer.call(__MODULE__, :manual_broadcast)
  end

    def init(_opts) do
    Logger.info("Genepool broadcaster started")

    # Add a small delay to ensure ETS table is ready
    Process.send_after(self(), :check_ets_and_start, 2000)

    {:ok, %{broadcasting: false}}
  end

  def handle_info(:broadcast_genes, state) do
    broadcast_gene_data()

    # Schedule the next broadcast
    schedule_broadcast()

    {:noreply, state}
  end

  def handle_info(:check_ets_and_start, state) do
    case :ets.info(@ets_table) do
      :undefined ->
        Logger.warning("ETS table #{@ets_table} not ready yet, retrying in 2 seconds")
        Process.send_after(self(), :check_ets_and_start, 2000)
        {:noreply, state}

      _ ->
        Logger.info("ETS table #{@ets_table} is ready, starting broadcast")
        schedule_broadcast()
        {:noreply, %{state | broadcasting: true}}
    end
  end

  def handle_call(:manual_broadcast, _from, state) do
    broadcast_gene_data()
    {:reply, :ok, state}
  end

  defp schedule_broadcast do
    Process.send_after(self(), :broadcast_genes, @broadcast_interval)
  end

  defp broadcast_gene_data do
    try do
      # Read all genes from ETS table
      genes = :ets.tab2list(@ets_table)
      |> Enum.map(fn {_id, state} -> state end)
      |> Enum.map(&format_gene_for_broadcast/1)

      # Get connected clients count

      # Broadcast to all clients subscribed to room:lobby
      GenoblendWeb.Endpoint.broadcast("room:lobby", "genes_update", %{
        genes: genes,
        timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
      })

      Logger.warn("Broadcasted #{length(genes)} genes to room:lobby")
    rescue
      error ->
        Logger.error("Failed to broadcast gene data: #{inspect(error)}")
    end
  end

  defp format_gene_for_broadcast(gene_state) do
    %{
      id: Map.get(gene_state, :id),
      name: Map.get(gene_state, :name),
      x_coordinate: Map.get(gene_state, :x_coordinate),
      y_coordinate: Map.get(gene_state, :y_coordinate),
      traits: Map.get(gene_state, :traits, []),
      description: Map.get(gene_state, :description),
      color: Map.get(gene_state, :color),
      is_alive: Map.get(gene_state, :is_alive, true),
      dead_at: Map.get(gene_state, :dead_at)
    }
  end
end
