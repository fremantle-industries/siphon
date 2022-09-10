defmodule Siphon.Repo do
  @moduledoc """
  Postgres backed in ecto repository for persistent data
  """

  use Ecto.Repo, otp_app: :siphon, adapter: Ecto.Adapters.Postgres
end
