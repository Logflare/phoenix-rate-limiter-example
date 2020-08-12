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

  def start_multi(session) do
    # Start on the rest of the cluster
    response = GenServer.multi_call(Node.list(), DynamicSupervisor, {:start, session})
    Logger.info("Multi called: #{inspect(response)}")
  end

  def start_local(session) do
    # Start on the local node
    spec = Supervisor.child_spec({Limiter.Server, session}, restart: :transient)

    DynamicSupervisor.start_child(@super, spec)
  end

  ######## Callbacks ########

  def handle_call({:start, session}, _from, state) do
    {:reply, start_local(session), state}
  end
end
