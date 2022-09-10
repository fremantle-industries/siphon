defmodule Siphon.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Siphon.Repo,
      {Oban, Application.fetch_env!(:siphon, Oban)}
    ]

    opts = [strategy: :one_for_one, name: Siphon.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
