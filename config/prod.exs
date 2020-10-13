use Mix.Config

config :phx_limit, PhxLimitWeb.Endpoint,
  url: [host: "elixirphoenixratelimiter.com", scheme: "https", port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json",
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base:
    System.get_env("SECRET_KEY_BASE") ||
      raise("""
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """),
  check_origin: [
    "https://www.elixirphoenixratelimiter.com",
    "https://elixirphoenixratelimiter.com",
    "https://phx-limit.gigalixirapp.com"
  ]

config :logger,
  level: :info,
  backends: [LogflareLogger.HttpBackend, Ink]

config :logflare_logger_backend,
  url: "https://api.logflare.app",
  level: :info,
  api_key: System.get_env("LOGFLARE_API_KEY"),
  source_id: "bd355f06-516c-4537-bfd6-83675654c1f8",
  flush_interval: 1_000,
  max_batch_size: 50

config :telemetry_metrics_logflare,
  ecto: [applications: :phx_limit],
  url: "https://api.logflare.app",
  api_key: System.get_env("LOGFLARE_API_KEY"),
  source_id: "804a7741-9348-4d27-9052-710a50ff3b2a",
  max_batch_size: 5,
  tick_interval: 1_000

config :libcluster,
  topologies: [
    k8s_example: [
      strategy: Cluster.Strategy.Kubernetes,
      config: [
        kubernetes_selector: System.get_env("LIBCLUSTER_KUBERNETES_SELECTOR"),
        kubernetes_node_basename: System.get_env("LIBCLUSTER_KUBERNETES_NODE_BASENAME")
      ]
    ]
  ]

# import_config "prod.secret.exs"
