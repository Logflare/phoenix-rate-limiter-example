defmodule PhxLimit.Limiter.Manager do
  require Logger

  use GenServer

  alias PhxLimit.Limiter

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def start_local(session) do
    GenServer.call(__MODULE__, {:start, session})
  end

  def start_multi(session) do
    # Start on the rest of the cluster
    response = GenServer.multi_call(Node.list(), __MODULE__, {:start, session})
    Logger.info("Multi called: #{inspect(response)}")
  end

  def handle_call({:start, session}, _from, state) do
    {:reply, Limiter.start(session), state}
  end
end
