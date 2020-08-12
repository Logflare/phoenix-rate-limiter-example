defmodule PhxLimitWeb.PageLive do
  use PhxLimitWeb, :live_view

  require Logger

  alias PhxLimitWeb.Router.Helpers, as: Routes
  alias Phoenix.PubSub
  alias PhxLimit.Limiter

  @impl true
  @rate_limit Application.get_env(:phx_limit, :rate_limit)

  def mount(%{"session_id" => sid}, %{"session_id" => _sid}, socket) do
    subscribe_and_assign(socket, sid)
  end

  def mount(_params, %{"session_id" => sid}, socket) do
    subscribe_and_assign(socket, sid)
  end

  @impl true
  def handle_info({:limits, [{node, limits}]}, socket) do
    case node == Node.self() do
      true ->
        {:noreply, assign(socket, limits: limits)}

      false ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:poll, %{assigns: %{session_id: sid}} = socket) do
    nodes_limits = Limiter.Cache.get_cluster_rates(sid)
    {_, acc} = Limiter.Cache.acc_cluster_rates(sid)

    socket =
      if acc.rate_avg > @rate_limit,
        do: put_flash(socket, :error, "Average cluster rate is #{acc.rate_avg}. Rate limited!"),
        else: socket

    poll_cluster_limits()

    {:noreply, assign(socket, nodes_limits: nodes_limits, acc_limits: acc)}
  end

  def poll_cluster_limits() do
    Process.send_after(self(), :poll, :timer.seconds(1))
  end

  defp subscribe_and_assign(socket, sid) do
    if connected?(socket) do
      Logger.info("Connected #{sid}")
      PubSub.subscribe(PhxLimit.PubSub, "limits:#{sid}")
      poll_cluster_limits()
    else
      Logger.info("Not connected #{sid}")
    end

    {:ok, assign(socket, session_id: sid, limits: :connecting, nodes_limits: [:connecting])}
  end
end
