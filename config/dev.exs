use Mix.Config

config :phx_limit, PhxLimitWeb.Endpoint,
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :phx_limit, PhxLimitWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/phx_limit_web/(live|views)/.*(ex)$",
      ~r"lib/phx_limit_web/templates/.*(eex)$"
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :logflare_logger_backend,
  url: "https://api.logflare.app",
  level: :info,
  api_key: "83CNxnKn0Zq4",
  source_id: "6462689c-2af3-4e51-904c-947f9b3df871",
  flush_interval: 1_000,
  max_batch_size: 50

config :libcluster,
  topologies: [
    dev: [
      strategy: Cluster.Strategy.Epmd,
      config: [
        hosts: [:"orange@127.0.0.1", :"pink@127.0.0.1"]
      ],
      connect: {:net_kernel, :connect_node, []},
      disconnect: {:net_kernel, :disconnect_node, []}
    ]
  ]

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
