defmodule PhxLimitWeb.Plugs.LogflareLogger do
  @moduledoc """
  A plug for logging basic request information in the format:
      GET /index.html
      Sent 200 in 572ms
  To use it, just plug it into the desired module.
      plug Plug.Logger, log: :debug
  ## Options
    * `:log` - The log level at which this plug should log its request info.
      Default is `:info`.
  """

  require Logger
  alias Plug.Conn
  @behaviour Plug

  def init(opts) do
    Keyword.get(opts, :log, :info)
  end

  def call(conn, level) do
    Logger.log(level, fn ->
      [conn.method, ?\s, conn.request_path]
    end)

    start = System.monotonic_time()

    Conn.register_before_send(conn, fn conn ->
      stop = System.monotonic_time()
      diff = System.convert_time_unit(stop - start, :native, :microsecond)
      status = Integer.to_string(conn.status)
      msg = [connection_type(conn), ?\s, status, " in ", formatted_diff(diff)]

      Logger.log(level, msg, response_time: diff, status: conn.status)

      conn
    end)
  end

  defp formatted_diff(diff) when diff > 1000, do: [diff |> div(1000) |> Integer.to_string(), "ms"]
  defp formatted_diff(diff), do: [Integer.to_string(diff), "µs"]

  defp connection_type(%{state: :set_chunked}), do: "Chunked"
  defp connection_type(_), do: "Sent"
end
