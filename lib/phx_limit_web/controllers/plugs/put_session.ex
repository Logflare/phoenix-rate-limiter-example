defmodule PhxLimitWeb.Plugs.PutSession do
  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{params: %{"session_id" => session_id}} = conn, _opts) do
    put_session(conn, :session_id, session_id)
  end

  def call(conn, _opts) do
    if get_session(conn, :session_id) do
      conn
    else
      put_session(conn, :session_id, Ecto.UUID.generate())
    end
  end
end
