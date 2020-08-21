use Mix.Config

config :phx_limit, PhxLimitWeb.Endpoint,
  url: [host: "phx-limit.gigalixirapp.com", port: 80],
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
      """)

config :logger,
  level: :info,
  backends: [LogflareLogger.HttpBackend, :console]

config :logflare_logger_backend,
  url: "https://api.logflare.app",
  level: :info,
  api_key: System.get_env("LOGFLARE_API_KEY"),
  source_id: "bd355f06-516c-4537-bfd6-83675654c1f8",
  flush_interval: 1_000,
  max_batch_size: 50

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
