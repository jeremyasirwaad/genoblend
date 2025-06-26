defmodule Genoblend.NearestPointFinder do
  @doc """
  Finds the nearest point to a given gene and returns the distance.
  Returns %{nearest_gene: gene, distance: float}
  """
  def find_nearest_point(target_gene, genes) do
    genes
    |> Enum.filter(fn gene -> gene.id != target_gene.id end)
    |> Enum.map(fn gene ->
      distance = calculate_distance(target_gene, gene)
      %{nearest_gene: gene, distance: distance}
    end)
    |> Enum.min_by(fn %{distance: distance} -> distance end)
  end

  @doc """
  Calculates the next coordinate to move towards the nearest point.
  Moves one unit closer to the target.
  Returns %{x_coordinate: float, y_coordinate: float}
  """
  def next_coordinate(current_gene, target_gene) do
    dx = target_gene.x_coordinate - current_gene.x_coordinate
    dy = target_gene.y_coordinate - current_gene.y_coordinate

    # Calculate the unit vector (direction)
    distance = calculate_distance(current_gene, target_gene)

    cond do
      distance == 0.0 ->
        # Already at target
        %{x_coordinate: current_gene.x_coordinate, y_coordinate: current_gene.y_coordinate}

      distance <= 1.0 ->
        # Close enough, move directly to target
        %{x_coordinate: target_gene.x_coordinate, y_coordinate: target_gene.y_coordinate}

      true ->
        # Move one unit towards target
        unit_x = dx / distance
        unit_y = dy / distance

        %{
          x_coordinate: current_gene.x_coordinate + unit_x,
          y_coordinate: current_gene.y_coordinate + unit_y
        }
    end
  end

  @doc """
  Finds the nearest point and calculates the next move towards it.
  Returns %{nearest_gene: gene, distance: float, next_coordinate: %{x: float, y: float}}
  """
  def find_nearest_and_next_move(target_gene, genes) do
    nearest_result = find_nearest_point(target_gene, genes)
    next_coord = next_coordinate(target_gene, nearest_result.nearest_gene)

    %{
      nearest_gene: nearest_result.nearest_gene,
      distance: nearest_result.distance,
      next_coordinate: next_coord
    }
  end

  @doc """
  Calculates Euclidean distance between two genes.
  """
  def calculate_distance(gene1, gene2) do
    dx = gene1.x_coordinate - gene2.x_coordinate
    dy = gene1.y_coordinate - gene2.y_coordinate
    :math.sqrt(dx * dx + dy * dy)
  end

  @doc """
  Alternative: Manhattan distance (faster calculation)
  """
  def calculate_manhattan_distance(gene1, gene2) do
    abs(gene1.x_coordinate - gene2.x_coordinate) +
    abs(gene1.y_coordinate - gene2.y_coordinate)
  end

  @doc """
  Creates a distance matrix for all genes (useful for analysis)
  """
  def create_distance_matrix(genes) do
    genes
    |> Enum.map(fn gene1 ->
      distances = genes
      |> Enum.map(fn gene2 ->
        if gene1.id == gene2.id do
          0.0
        else
          calculate_distance(gene1, gene2)
        end
      end)
      {gene1.name, distances}
    end)
    |> Enum.into(%{})
  end

  @doc """
  Optimized version using spatial partitioning for larger datasets
  """
  def find_nearest_points_optimized(genes, grid_size \\ 10) do
    # Create spatial grid for faster lookups
    grid = create_spatial_grid(genes, grid_size)

    genes
    |> Enum.map(fn gene ->
      nearest = find_nearest_in_grid(gene, grid, grid_size)
      {gene, nearest.gene, nearest.distance}
    end)
  end

  # Helper function to create spatial grid
  defp create_spatial_grid(genes, grid_size) do
    cell_width = 200.0 / grid_size
    cell_height = 200.0 / grid_size

    genes
    |> Enum.group_by(fn gene ->
      grid_x = min(trunc(gene.x_coordinate / cell_width), grid_size - 1)
      grid_y = min(trunc(gene.y_coordinate / cell_height), grid_size - 1)
      {grid_x, grid_y}
    end)
  end

  # Helper function to find nearest point using spatial grid
  defp find_nearest_in_grid(target_gene, grid, grid_size) do
    cell_width = 200.0 / grid_size
    cell_height = 200.0 / grid_size

    target_grid_x = min(trunc(target_gene.x_coordinate / cell_width), grid_size - 1)
    target_grid_y = min(trunc(target_gene.y_coordinate / cell_height), grid_size - 1)

    # Check surrounding cells (3x3 grid around target)
    candidates = for x <- (target_grid_x - 1)..(target_grid_x + 1),
                     y <- (target_grid_y - 1)..(target_grid_y + 1),
                     x >= 0 and x < grid_size and y >= 0 and y < grid_size,
                     genes = Map.get(grid, {x, y}, []),
                     genes != [] do
      genes
    end
    |> List.flatten()
    |> Enum.filter(fn gene -> gene.id != target_gene.id end)

    # If no candidates in surrounding cells, fall back to full search
    candidates = if Enum.empty?(candidates) do
      grid
      |> Map.values()
      |> List.flatten()
      |> Enum.filter(fn gene -> gene.id != target_gene.id end)
    else
      candidates
    end

    candidates
    |> Enum.map(fn gene ->
      distance = calculate_distance(target_gene, gene)
      %{gene: gene, distance: distance}
    end)
    |> Enum.min_by(fn %{distance: distance} -> distance end)
  end
end
