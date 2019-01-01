defmodule Disclist.Repo.Migrations.AddLocation do
  use Ecto.Migration

  def change do
    alter table("craigslist_results") do
      add :location, :string
    end
  end
end
