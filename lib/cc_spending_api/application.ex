defmodule CcSpendingApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CcSpendingApiWeb.Telemetry,
      CcSpendingApi.Repo,
      {DNSCluster, query: Application.get_env(:cc_spending_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CcSpendingApi.PubSub},
      # Start a worker by calling: CcSpendingApi.Worker.start_link(arg)
      # {CcSpendingApi.Worker, arg},
      # Start to serve requests, typically the last entry
      # TODO: DELETE FILE and use Guardian.DB default sweeper
      # {Guardian.DB.Token.Sweeper, []}
      {Guardian.DB.Sweeper, []},
      # CcSpendingApi.Authentication.Infra.GuardianCleanupWorker,
      CcSpendingApiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CcSpendingApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CcSpendingApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
