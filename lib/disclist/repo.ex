defmodule Disclist.Repo do
  use Ecto.Repo, 
    otp_app: :disclist,
    adapter: Ecto.Adapters.Postgres
end
