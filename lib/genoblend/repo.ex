defmodule Genoblend.Repo do
  use Ecto.Repo,
    otp_app: :genoblend,
    adapter: Ecto.Adapters.Postgres
end
