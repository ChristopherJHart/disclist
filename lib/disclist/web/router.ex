defmodule Disclist.Web.Router do
  use Plug.Router
  alias Disclist.Stats

  plug(:match)
  plug(:dispatch)

  get "/stats" do
    unique_results = Stats.count_total_results()
    unique_queries = Stats.count_total_queries()
    unique_channels = Stats.count_total_channels()

    data = """
    <h2> Stats </h2>
    Currently #{unique_results} unique posts scraped by #{unique_queries} 
    unique queries published to #{unique_channels} unique Discord channels.
    """

    send_resp(conn, 200, data)
  end

  get "/api/stats/posts_scraped" do
    unique_results = Stats.count_total_results()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{data: unique_results}))
  end

  get "/api/stats/searches_tracked" do
    unique_results = Stats.count_total_queries()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{data: unique_results}))
  end

  get "/api/stats/channels_active" do
    unique_results = Stats.count_total_queries()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{data: unique_results}))
  end

  match _ do
    send_resp(conn, 200, "up and running")
  end
end
