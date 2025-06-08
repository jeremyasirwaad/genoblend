defmodule Genoblend.Genservers.GenesManager do
  use GenServer
  require Logger
  alias Genoblend.Genservers.GenepoolManager

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
      user_id: gene.user_id
    }

    {:ok, initial_gene_state}
  end

  def handle_call(:gene_info, _from, state) do
    {:reply, state, state}
  end
end
