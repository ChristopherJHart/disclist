defmodule Disclist.Repo.Migrations.CreateCraigslistQueriesTable do
  use Ecto.Migration

  def change do
    create table("craigslist_queries") do
      add :city, :string, null: false
      add :query_string, :string, null: false
      add :channel_id, :id, null: false
    end
    create unique_index("craigslist_queries", [:city, :query_string])
  end
end
