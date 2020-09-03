defmodule PhxLimit.Limiter.Server do
  require Logger

  use GenServer

  alias __MODULE__
  alias PhxLimit.Limiter.Cache
  alias Phoenix.PubSub

  @server __MODULE__
  @idle_shutdown :timer.seconds(60)
  @tick :timer.seconds(1)
  @bucket_len 60

  defstruct timers: [],
            og_session: %{},
            session_id: nil,
            counter: nil,
            rate_counter: nil,
            counter_last: 0,
            rate_avg: 0,
            rate_bucket: [],
            message: :initialized,
            nodes_limits: []

  def start_link(%{session_id: sid} = session) do
    GenServer.start_link(@server, session, name: String.to_atom(sid))
  end

  def init(session) do
    PubSub.subscribe(PhxLimit.PubSub, "limits:#{session.session_id}")

    t_ref = idle_shutdown()
    c_ref = init_counter(session.session_id)
    bucket = LQueue.new(@bucket_len)

    state = %Server{
      og_session: session,
      session_id: session.session_id,
      timers: [t_ref],
      rate_counter: c_ref,
      rate_bucket: bucket
    }

    tick()

    Logger.info("Limiter started: #{session.session_id}", session)

    {:ok, state}
  end

  def add(session_id, count \\ 1) do
    ref = :persistent_term.get(session_id)
    :ok = :counters.add(ref, 1, count)

    GenServer.cast(String.to_atom(session_id), :reset_timers)

    :counters.get(ref, 1)
  end

  def sub(session_id, count \\ 1) do
    ref = :persistent_term.get(session_id)
    :ok = :counters.sub(ref, 1, count)
    :counters.get(ref, 1)
  end

  def get_counter(session_id) do
    ref = :persistent_term.get(session_id)
    :counters.get(ref, 1)
  end

  ######## Callbacks ########

  def handle_cast(:reset_timers, state) do
    ref = reset_timers(state.timers)

    {:noreply, %Server{state | timers: [ref]}}
  end

  def handle_info(:tick, state) do
    last = state.counter_last
    rate = get_counter(state.session_id) - last
    _count = sub(state.session_id, last)

    bucket = LQueue.push(state.rate_bucket, rate)
    avg = Kernel.round(Enum.sum(bucket) / @bucket_len)

    broadcast(avg, rate, state.message, state.session_id)

    tick()

    {:noreply, %Server{state | rate_bucket: bucket, rate_avg: avg, counter_last: rate}}
  end

  def handle_info(:shutdown, state) do
    broadcast(state.rate_avg, state.counter_last, :shutdown, state.session_id)

    Logger.info("Limiter shutdown #{state.session_id}")
    {:stop, :normal, state}
  end

  def handle_info({:limits, [{node, limits}]}, state) do
    nodes_limits = Keyword.put(state.nodes_limits, node, limits)

    Cache.put(state.session_id, nodes_limits)

    {:noreply, %{state | nodes_limits: nodes_limits}}
  end

  defp init_counter(session_id) do
    ref = :counters.new(1, [:write_concurrency])
    :ok = :persistent_term.put(session_id, ref)

    ref
  end

  ######## Private ########

  defp reset_timers(timers) when is_list(timers) do
    # We should really only have one timer we need to cancel
    for t <- timers do
      Process.cancel_timer(t)
    end

    idle_shutdown()
  end

  defp tick() do
    Process.send_after(self(), :tick, @tick)
  end

  defp idle_shutdown() do
    Process.send_after(self(), :shutdown, @idle_shutdown)
  end

  defp broadcast(avg, rate, message, session_id) when is_binary(session_id) do
    PubSub.broadcast!(
      PhxLimit.PubSub,
      "limits:#{session_id}",
      {:limits, [{Node.self(), %{rate_avg: avg, counter_last: rate, message: message}}]}
    )
  end
end
