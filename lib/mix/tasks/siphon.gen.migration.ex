defmodule Mix.Tasks.Siphon.Gen.Migration do
  @shortdoc "Generates migrations for siphon"

  @moduledoc """
  Generates the required database migrations for siphon.
  """
  use Mix.Task

  import Mix.Ecto
  import Mix.Generator

  @migrations_path "priv/templates/migrations"

  @doc false
  def run(args) do
    no_umbrella!("ecto.gen.migration")

    repos = parse_repo(args)

    Enum.each(repos, fn repo ->
      ensure_repo(repo, args)
      path = Ecto.Migrator.migrations_path(repo)
      app_dir = Application.app_dir(:siphon)
      app_migrations_path = Path.join(app_dir, @migrations_path)
      {:ok, migrations} = app_migrations_path |> File.ls()
      source_paths = Enum.map(migrations, &Path.join(app_migrations_path, &1))
      app_module = get_app_module()

      generated_files =
        source_paths
        |> Enum.map(fn source_path ->
          EEx.eval_file(source_path,
            module_prefix: app_module,
            migration_prefix: Siphon.Migrations.migration_prefix(),
            oban_table_prefix: Siphon.Migrations.oban_table_prefix()
          )
        end)

      target_files =
        source_paths
        |> Enum.map(fn source_path ->
          basename = Path.basename(source_path, ".eex")
          Path.join(path, basename)
        end)

      Enum.map(target_files, &IO.inspect/1)
      create_directory(path)

      [target_files, generated_files]
      |> Enum.zip()
      |> Enum.each(fn {target_file, generated_file} ->
        create_file(target_file, generated_file)
      end)
    end)
  end

  defp get_app_module do
    Mix.Project.config()
    |> Keyword.fetch!(:app)
    |> to_string()
    |> Macro.camelize()
  end
end
