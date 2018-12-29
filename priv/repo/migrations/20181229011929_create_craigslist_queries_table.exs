defmodule Disclist.Repo.Migrations.CreateCraigslistQueriesTable do
  use Ecto.Migration

  def change do
    create table("craigslist_queries") do
      add :city, :string, null: false
      add :query_string, :text, null: false
      add :channel_id, :bigint, null: false
    end
    create unique_index("craigslist_queries", [:city, :query_string])
  end
end
