defmodule PhxLimit.Limiter.Client do
  alias Phoenix.PubSub
  alias PhxLimit.PubSubRates.Cache

  require Logger

  use GenServer

  def start_link() do
    GenServer.start_link(
      __MODULE__,
      [],
      name: __MODULE__
    )
  end

  def init(state) do
    PubSub.subscribe(PhxLimit.PubSub, "rates")

    {:ok, state}
  end

  def handle_info({:rates, source_id, rates}, state) do
    Cache.cache_rates(source_id, rates)
    {:noreply, state}
  end
end
