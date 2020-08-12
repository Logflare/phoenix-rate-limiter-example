defmodule PhxLimitWeb.PageLive do
  use PhxLimitWeb, :live_view

  require Logger

  alias PhxLimitWeb.Router.Helpers, as: Routes
  alias Phoenix.PubSub

  @impl true

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
    cluster_limits = PhxLimit.Limiter.Cache.get_cluster_rates(sid)
    poll_cluster_limits()
    {:noreply, assign(socket, :cluster_limits, cluster_limits)}
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

    {:ok, assign(socket, session_id: sid, limits: :connecting, cluster_limits: [:connecting])}
  end
end
