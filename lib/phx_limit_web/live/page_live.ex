defmodule PhxLimitWeb.PageLive do
  use PhxLimitWeb, :live_view

  alias PhxLimitWeb.Router.Helpers, as: Routes

  @impl true
  def mount(_params, %{"session_id" => sid}, socket) do
    {:ok, assign(socket, session_id: sid)}
  end

  @impl true
  def handle_event("reset", _params, socket) do
    sid = Ecto.UUID.generate()

    {:noreply,
     push_redirect(socket,
       to: Routes.page_path(socket, :index, %{session_id: sid})
     )}
  end

  @impl true
  def handle_params(%{"session_id" => sid}, _uri, socket) do
    {:noreply, assign(socket, :session_id, sid)}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
