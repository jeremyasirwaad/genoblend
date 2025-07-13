defmodule Genoblend.Genservers.GeneeventBroadcaster do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_opts) do
    Logger.info("Gene event broadcaster started")
    {:ok, %{}}
  end

  def broadcast_gene_birth(gene_name, parent1_name \\ nil, parent2_name \\ nil) do
    GenServer.cast(__MODULE__, {:gene_birth, gene_name, parent1_name, parent2_name})
  end

  def broadcast_gene_death(gene_name, age_seconds \\ nil) do
    GenServer.cast(__MODULE__, {:gene_death, gene_name, age_seconds})
  end

  def broadcast_fusion_declared(parent1_name, parent2_name, child_name) do
    GenServer.cast(__MODULE__, {:fusion_declared, parent1_name, parent2_name, child_name})
  end

  def broadcast_environment_started() do
    GenServer.cast(__MODULE__, {:environment_started})
  end

  def broadcast_generation_milestone(generation_number) do
    GenServer.cast(__MODULE__, {:generation_milestone, generation_number})
  end

  def handle_cast({:gene_birth, gene_name, nil, nil}, state) do
    # Initial gene birth (no parents)
    Logger.info("Handling gene birth event for: #{gene_name}")
    broadcast_event(%{
      title: "New Gene Born",
      type: "birth",
      short_message: "#{gene_name} has emerged in the gene pool"
    })
    {:noreply, state}
  end

  def handle_cast({:gene_birth, gene_name, parent1_name, parent2_name}, state) do
    # Gene birth from fusion
    Logger.info("Handling gene birth event for: #{gene_name} from parents #{parent1_name} and #{parent2_name}")
    broadcast_event(%{
      title: "Offspring Created",
      type: "birth",
      short_message: "#{gene_name} was born from #{parent1_name} and #{parent2_name}"
    })
    {:noreply, state}
  end

  def handle_cast({:gene_death, gene_name, age_seconds}, state) do
    age_text = if age_seconds do
      minutes = div(age_seconds, 60)
      "after #{minutes} minutes"
    else
      ""
    end
    
    broadcast_event(%{
      title: "Gene Died",
      type: "death",
      short_message: "#{gene_name} has died #{age_text}"
    })
    {:noreply, state}
  end

  def handle_cast({:fusion_declared, parent1_name, parent2_name, child_name}, state) do
    Logger.info("Handling fusion event: #{parent1_name} + #{parent2_name} -> #{child_name}")
    broadcast_event(%{
      title: "Fusion Complete",
      type: "fusion",
      short_message: "#{parent1_name} and #{parent2_name} fused to create #{child_name}"
    })
    {:noreply, state}
  end

  def handle_cast({:environment_started}, state) do
    Logger.info("Handling environment started event")
    broadcast_event(%{
      title: "Environment Initialized",
      type: "system",
      short_message: "Gene pool environment has been initialized with starter genes"
    })
    {:noreply, state}
  end

  def handle_cast({:generation_milestone, generation_number}, state) do
    broadcast_event(%{
      title: "Generation Milestone",
      type: "milestone",
      short_message: "Generation #{generation_number} has been reached!"
    })
    {:noreply, state}
  end

  defp broadcast_event(event_data) do
    Logger.warning("Broadcasting event to room:events - type: #{event_data.type}")

    GenoblendWeb.Endpoint.broadcast("room:events", "event_update", %{
      title: event_data.title,
      type: event_data.type,
      short_message: event_data.short_message,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    })
  end
end