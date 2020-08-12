defmodule PhxLimit.Limiter.Cache do
  require Logger

  import Cachex.Spec

  alias __MODULE__
  @ttl :timer.seconds(60)

  defstruct counter_last: 0, message: :no_cache, rate_avg: 0

  def child_spec(_) do
    cachex_opts = [
      expiration: expiration(default: @ttl)
    ]

    %{
      id: Cache,
      start: {Cachex, :start_link, [Cache, cachex_opts]}
    }
  end

  def put(session_id, rates) do
    Cachex.put(Cache, session_id, rates)
  end

  def get_cluster_rates(session_id) do
    case Cachex.get(Cache, session_id) do
      {:ok, nil} ->
        [{Node.self(), %Cache{}}]

      {:ok, rates} ->
        rates

      {:error, _message} ->
        [{Node.self(), %Cache{}}]
    end
  end

  def acc_cluster_rates(session_id) do
    rates = get_cluster_rates(session_id)

    Enum.reduce(rates, fn {_, x}, {_, acc} ->
      {:cluster,
       %Cache{
         counter_last: x.counter_last + acc.counter_last,
         message: :initialized,
         rate_avg: x.rate_avg + acc.rate_avg
       }}
    end)
  end
end
