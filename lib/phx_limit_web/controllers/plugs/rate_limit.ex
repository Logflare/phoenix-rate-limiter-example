defmodule PhxLimitWeb.Plugs.RateLimit do
  import Plug.Conn

  alias PhxLimit.Limiter.{Cache, Server}

  @rate_limit Application.get_env(:phx_limit, :rate_limit)

  def init(opts), do: opts

  def call(%Plug.Conn{params: %{"session_id" => session_id}} = conn, _opts) do
    rate_limit(conn, session_id)
  end

  def call(conn, _opts) do
    case get_session(conn, :session_id) do
      nil ->
        conn |> send_resp(403, "Session not found") |> halt()

      session_id ->
        rate_limit(conn, session_id)
    end
  end

  defp rate_limit(conn, session_id) do
    {_, %{rate_avg: rate}} = Cache.acc_cluster_rates(session_id)

    case rate in 0..@rate_limit do
      true ->
        Server.add(session_id)
        conn

      false ->
        conn |> send_resp(403, "Rate limited!") |> halt()
    end
  end
end
