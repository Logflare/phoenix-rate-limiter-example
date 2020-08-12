defmodule PhxLimit.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      {Cluster.Supervisor, [topologies, [name: PhxLimit.ClusterSupervisor]]},
      # Start the Telemetry supervisor
      PhxLimitWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: PhxLimit.PubSub},
      PhxLimit.Limiter.Cache,
      PhxLimit.Limiter,
      PhxLimit.Limiter.Manager,
      PhxLimitWeb.Endpoint
      # Start a worker by calling: PhxLimit.Worker.start_link(arg)
      # {PhxLimit.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhxLimit.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PhxLimitWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
