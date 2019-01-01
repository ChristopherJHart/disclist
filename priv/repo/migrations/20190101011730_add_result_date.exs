defmodule Disclist.Repo.Migrations.AddResultDate do
  use Ecto.Migration

  def change do
    alter table("craigslist_results") do
      add :result_datetime, :naive_datetime
    end
  end
end
