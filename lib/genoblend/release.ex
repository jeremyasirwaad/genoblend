defmodule Genoblend.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :genoblend

  def migrate do
    load_app()

    # Database disabled - skip migrations
    case Application.fetch_env(@app, :ecto_repos) do
      {:ok, repos} when is_list(repos) and repos != [] ->
        for repo <- repos do
          {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
        end
      _ ->
        IO.puts("No database configured - skipping migrations")
        :ok
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    case Application.fetch_env(@app, :ecto_repos) do
      {:ok, repos} -> repos
      :error -> []
    end
  end

  defp load_app do
    Application.load(@app)
  end
end
