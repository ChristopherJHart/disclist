defmodule Disclist.Repo.Migrations.CreateCraigslistResultsTable do
  use Ecto.Migration

  def change do
    create table("craigslist_results") do
      add :data_id, :bigint
      add :datetime, :naive_datetime
      add :price, :float
      add :title, :text
      add :url, :string
      add :postingbody, :text
      add :image_urls, {:array, :string}
      add :published, :boolean, default: false
    end
  end
end
