import Config

# Database
env = config_env() |> Atom.to_string()
partition = System.get_env("MIX_TEST_PARTITION")
default_database_url = "ecto://postgres:postgres@localhost:5432/siphon_?"
configured_database_url = System.get_env("DATABASE_URL") || default_database_url
database_url = "#{String.replace(configured_database_url, "?", env)}#{partition}"
database_pool_size = String.to_integer(System.get_env("POOL_SIZE") || "10")
siphon_schema_prefix = System.get_env("SIPHON_SCHEMA_PREFIX", nil)
oban_table_prefix = System.get_env("SIPHON_OBAN_TABLE_PREFIX", nil)

config :siphon, Siphon.Repo,
       url: database_url,
       pool_size: database_pool_size

if siphon_schema_prefix != nil do
  set_search_path_query_args = ["SET search_path TO #{siphon_schema_prefix}", []]
  config :siphon, Siphon.Repo,
    migration_default_prefix: "#{siphon_schema_prefix}",
    after_connect: {Postgrex, :query!, set_search_path_query_args}
end

# Oban Job Processing
if oban_table_prefix != nil do
  config :siphon, Oban, prefix: oban_table_prefix
end

config :siphon, Oban,
  repo: Siphon.Repo,
  plugins: [
    Oban.Plugins.Pruner
    # {
    #   Oban.Plugins.Cron,
    #   crontab: [
    #     {"* * * * *", MyApp.MinuteWorker},
    #     {"0 * * * *", MyApp.HourlyWorker, args: %{custom: "arg"}},
    #     {"0 0 * * *", MyApp.DailyWorker, max_attempts: 1},
    #     {"0 12 * * MON", MyApp.MondayWorker, queue: :scheduled, tags: ["mondays"]},
    #     {"@daily", MyApp.AnotherDailyWorker}
    #   ]
    # }
  ],
  queues: [default: 10, imports: 5]

# Logger
config :logger,
  level: :info,
  backends: [{LoggerFileBackend, :file_log}],
  utc_log: true

config :logger, :file_log, path: "./logs/#{Mix.env()}.log"

if System.get_env("DEBUG") == "true" do
  config :logger, level: :debug
end

# Dev
if config_env() == :dev do
  config :siphon, Siphon.Repo, show_sensitive_data_on_connection_error: true
end

# Test
if config_env() == :test do
  config :siphon, Siphon.Repo,
    pool: Ecto.Adapters.SQL.Sandbox,
    show_sensitive_data_on_connection_error: true

  config :siphon, Oban, testing: :inline
end
