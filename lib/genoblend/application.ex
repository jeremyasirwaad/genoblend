defmodule Genoblend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GenoblendWeb.Telemetry,
      Genoblend.Repo,
      {DNSCluster, query: Application.get_env(:genoblend, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Genoblend.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Genoblend.Finch},
      # Start a worker by calling: Genoblend.Worker.start_link(arg)
      # {Genoblend.Worker, arg},
      # Start to serve requests, typically the last entry
      {Genoblend.Genservers.GenepoolManager, []},
      GenoblendWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Genoblend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GenoblendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
