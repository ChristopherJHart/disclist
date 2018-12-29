defmodule Disclist.Craigslist.Result do
  use Ecto.Schema
  import Ecto.Changeset

  schema "craigslist_results" do
    field(:data_id, :id)
    field(:datetime, :naive_datetime)
    field(:price, :float)
    field(:title, :string)
    field(:url, :string)
    field(:postingbody, :string)
    field(:image_urls, {:array, :string})
    field(:published, :boolean, default: false)
  end

  def changeset(result, params \\ %{}) do
    result
    |> cast(params, [:data_id, :datetime, :price, :title, :url, :postingbody, :image_urls, :published])
    |> validate_required(:data_id)
    |> unsafe_validate_unique([:data_id], Disclist.Repo, message: "Result id already exists")
  end
end
