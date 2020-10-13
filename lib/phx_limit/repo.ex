defmodule PhxLimit.Repo do
  require Logger

  use Ecto.Repo,
    otp_app: :phx_limit,
    adapter: Ecto.Adapters.Postgres
end
