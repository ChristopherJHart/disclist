defmodule Disclist.Craigslist.Query do
  use Ecto.Schema
  import Ecto.Changeset

  schema "craigslist_queries" do
    field(:city, :string)
    field(:query_string, :string)
    field(:channel_id, :id)
  end

  def changeset(query, params \\ %{}) do
    query
    |> cast(params, [:city, :query_string, :channel_id])
    |> validate_required([:city, :query_string, :channel_id])
    |> unsafe_validate_unique([:city, :query_string], Disclist.Repo,
      message: "Querystring for that city already exists"
    )
    |> validate_query_string()
  end

  def validate_query_string(%{valid: true} = change) do
    query_string = get_change(change, :query_string)

    try do
      _ =
        query_string
        |> URI.query_decoder()
        |> Enum.to_list()

      change
    rescue
      exception -> add_error(change, :query_string, Exception.message(exception))
    end
  end

  def validate_query_string(invalid), do: invalid
end
