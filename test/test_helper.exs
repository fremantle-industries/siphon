ExUnit.configure(formatters: [ExUnit.CLIFormatter, ExUnitNotifier])
Ecto.Adapters.SQL.Sandbox.mode(Siphon.Repo, :manual)
ExUnit.start()
