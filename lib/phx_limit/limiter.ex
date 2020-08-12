defmodule PhxLimit.Limiter do
  alias __MODULE__

  require Logger

  use DynamicSupervisor

  @super __MODULE__

  def start_link(args) do
    DynamicSupervisor.start_link(@super, args, name: @super)
  end

  def init(_state) do
    DynamicSupervisor.init(max_children: 10_000, strategy: :one_for_one)
  end

  def start(session) do
    spec = Supervisor.child_spec({Limiter.Server, session}, restart: :transient)

    DynamicSupervisor.start_child(@super, spec)
  end
end
