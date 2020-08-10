defmodule PhxLimit.Limiter.Server do
  require Logger

  use GenServer

  @server __MODULE__

  def start_link(session) do
    GenServer.start_link(@server, session)
  end

  def bump() do
    GenServer.call(@server, :bump)
  end

  def init(session) do
    Logger.info("Limiter started: #{session.session_id}", session)
    state = Map.put(%{}, :session, session)
    {:ok, state}
  end

  def handle_call(:bump, _from, state) do
    Logger.info("Bumped")
    {:reply, {:ok, :bumped}, state}
  end
end
