defmodule PhxLimitWeb.Plugs.SpawnSession do
  import Plug.Conn

  alias PhxLimit.Limiter

  def init(opts), do: opts

  def call(%Plug.Conn{params: %{"session_id" => session_id}} = conn, _opts) do
    spawn_session(conn, session_id)
  end

  def call(conn, _opts) do
    case get_session(conn, :session_id) do
      nil -> spawn_session(conn)
      session_id -> spawn_session(conn, session_id)
    end
  end

  defp spawn_session(conn), do: spawn_session(conn, Ecto.UUID.generate())

  defp spawn_session(conn, session_id) do
    case Limiter.start(%{session_id: session_id}) do
      {:ok, _ref} ->
        put_session(conn, :session_id, session_id)

      {:error, {:already_started, _ref}} ->
        Limiter.Server.add(session_id)
        put_session(conn, :session_id, session_id)

      {:error, :max_children} ->
        conn |> send_resp(403, "Rate limited") |> halt()
    end
  end
end
