use Mix.Config

config :phx_limit,
  rate_limit: 10

config :phx_limit, PhxLimitWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "uZtkhUnYzmXAnvKEn3eFqLZsic7+U/grUuNQrlP2kQB+igg52BucWS6QKWC2LRGl",
  render_errors: [view: PhxLimitWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PhxLimit.PubSub,
  live_view: [signing_salt: "ttphKCXq"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger, Ink, name: "PhxLimit"

config :phoenix, :json_library, Jason

config :phoenix, :logger, false

import_config "#{Mix.env()}.exs"
