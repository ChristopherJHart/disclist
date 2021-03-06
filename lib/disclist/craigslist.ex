defmodule Disclist.Craigslist do
  alias Disclist.{Repo, Craigslist.Query, Craigslist.Result}
  use Tesla
  import Ecto.Query, warn: false

  # plug(Tesla.Middleware.Logger)

  def new_query(params) do
    %Query{}
    |> Query.changeset(params)
    |> Repo.insert()
  end

  def list_queries do
    Repo.all(Query)
  end

  def get_query_by_city_and_query_string(channel_id, city, query_string) do
    Repo.one(
      from(q in Query,
        where: q.channel_id == ^channel_id and q.city == ^city and q.query_string == ^query_string
      )
    )
  end

  def delete_query!(%Query{} = query) do
    Repo.delete!(query)
  end

  def new_result(params) do
    %Result{}
    |> Result.changeset(params)
    |> Repo.insert()
  end

  def get_result(params) do
    Repo.get_by(Result, params)
  end

  def mark_result(result) do
    result
    |> Result.changeset(%{published: true})
    |> Repo.update!()
  end

  def list_results do
    Repo.all(Result)
  end

  def url(city_id) do
    "https://#{city_id}.craigslist.org"
  end

  def search_client(city_id, query_string) when is_binary(query_string) do
    params =
      query_string
      |> URI.query_decoder()
      |> Enum.to_list()

    search_client(city_id, params)
  end

  def search_client(city_id, params) when is_list(params) do
    middleware = [
      {Tesla.Middleware.BaseUrl, url(city_id)},
      {Tesla.Middleware.Headers, []},
      {Tesla.Middleware.Query, params}
    ]

    Tesla.client(middleware)
  end

  def result_client() do
    middleware = [
      {Tesla.Middleware.Headers, []}
    ]

    Tesla.client(middleware)
  end

  def result(url) when is_binary(url) do
    result_client()
    |> get(url)
    |> case do
      {:ok, %{body: html}} -> decode_result(html)
      er -> er
    end
  end

  def search(city_id, params) do
    city_id
    |> search_client(params)
    |> get("/search/sss")
    |> case do
      {:ok, %{body: html}} -> decode_search(html)
      er -> er
    end
  end

  def decode_search(html) do
    results =
      html
      |> Floki.find(".result-info")

    Enum.reduce(results, [], fn html, acc ->
      price =
        html
        |> Floki.find(".result-price")
        |> decode_price()

      {title, url, data_id} =
        html
        |> Floki.find(".result-title")
        |> decode_url_and_id()

      result_datetime =
        html
        |> Floki.find(".result-date")
        |> decode_datetime()

      [
        %{
          price: price,
          url: url,
          data_id: data_id,
          title: title,
          result_datetime: result_datetime
        }
        | acc
      ]
    end)
  end

  def decode_result(html) do
    postingbody =
      html
      |> Floki.find("#postingbody")
      |> decode_posting_body()

    image_urls =
      html
      |> Floki.find("[data-imgid]")
      |> Floki.find("img")
      |> Enum.map(fn {"img", [{"src", img} | _], _} -> img end)

    datetime =
      html
      |> Floki.find(".date")
      |> decode_datetime()

    location =
      html
      |> Floki.find("a")
      |> decode_location()

    %{postingbody: postingbody, image_urls: image_urls, datetime: datetime, location: location}
  end

  def decode_location([_, {"a", [{"href", "/"}], [location]} | _]) do
    String.trim(location)
  end

  def decode_location(_), do: nil

  def decode_price([{"span", [{"class", "result-price"}], ["$" <> price]}]) do
    case Float.parse(price) do
      {price, _} -> price
      _ -> nil
    end
  end

  def decode_price(_), do: nil

  def decode_url_and_id([{"a", [{"href", url}, {"data-id", id}, _], [title]} | _]) do
    {title, url, String.to_integer(id)}
  end

  def decode_url_and_id(_), do: {nil, nil, nil}

  def decode_datetime([{"time", [_, {"datetime", dt}], _} | _]) do
    case NaiveDateTime.from_iso8601(dt) do
      {:ok, ndt} -> ndt
      _ -> nil
    end
  end

  def decode_datetime([{"time", [_, {"datetime", dt}, _], _}]) do
    case Timex.parse(dt, "%Y-%m-%d %H:%M", :strftime) do
      {:ok, ndt} -> ndt
      _ -> nil
    end
  end

  def decode_datetime(_), do: nil

  def decode_posting_body([{_, _, [_, body]}]) do
    String.trim(body)
  end

  def decode_posting_body([{_, _, [_, body | rest]}]) when is_binary(body) do
    String.trim(body <> Floki.text(rest))
  end

  def decode_posting_body([{_, _, [_, body | rest]}]) do
    String.trim(Floki.text(body) <> Floki.text(rest))
  end

  def decode_posting_body(_), do: nil
end
