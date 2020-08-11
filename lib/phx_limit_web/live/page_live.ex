defmodule PhxLimitWeb.PageLive do
  use PhxLimitWeb, :live_view

  alias PhxLimitWeb.Router.Helpers, as: Routes
  alias Phoenix.PubSub

  @impl true
  def mount(_params, %{"session_id" => sid}, socket) do
    PubSub.subscribe(PhxLimit.PubSub, "limits:#{sid}")
    {:ok, assign(socket, session_id: sid, limits: %{})}
  end

  def mount(%{"session_id" => sid}, _session, socket) do
    PubSub.subscribe(PhxLimit.PubSub, "limits:#{sid}")
    {:ok, assign(socket, session_id: sid), limits: %{}}
  end

  @impl true
  def handle_info({:limits, limits}, socket) do
    {:noreply, assign(socket, limits: limits)}
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
end
