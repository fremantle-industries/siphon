defmodule Siphon.Migrations do
  @spec migration_prefix :: atom | nil
  def migration_prefix do
    Application.get_env(:siphon, Siphon.Repo)[:migration_default_prefix]
  end

  @spec oban_table_prefix :: atom | nil
  def oban_table_prefix do
    Application.get_env(:siphon, Oban)[:prefix]
  end
end
