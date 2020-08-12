defmodule PhxLimitWeb.PageLive do
  use PhxLimitWeb, :live_view

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

  @impl true
  @spec handle_event(<<_::40>>, any, Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("reset", _params, socket) do
    sid = Ecto.UUID.generate()

    {:noreply,
     push_redirect(socket,
       to: Routes.page_path(socket, :index, %{session_id: sid})
     )}
  end

  def poll_cluster_limits() do
    Process.send_after(self(), :poll, :timer.seconds(1))
  end

  defp subscribe_and_assign(socket, sid) do
    if connected?(socket) do
      PubSub.subscribe(PhxLimit.PubSub, "limits:#{sid}")
      poll_cluster_limits()
    end

    {:ok, assign(socket, session_id: sid, limits: :connecting, cluster_limits: [:connecting])}
  end
end
