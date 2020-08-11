defmodule PhxLimitWeb.PageLive do
  use PhxLimitWeb, :live_view

  alias PhxLimitWeb.Router.Helpers, as: Routes
  alias Phoenix.PubSub

  @impl true
  def mount(_params, %{"session_id" => sid}, socket) do
    PubSub.subscribe(PhxLimit.PubSub, "limits:#{sid}")
    poll_cluster_limits()
    {:ok, assign(socket, session_id: sid, limits: %{}, cluster_limits: %{})}
  end

  def mount(%{"session_id" => sid}, _session, socket) do
    PubSub.subscribe(PhxLimit.PubSub, "limits:#{sid}")
    poll_cluster_limits()
    {:ok, assign(socket, session_id: sid), limits: %{}, cluster_limits: %{}}
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

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def poll_cluster_limits() do
    Process.send_after(self(), :poll, :timer.seconds(1))
  end
end
