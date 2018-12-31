defmodule Disclist.Web.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/stats" do
    alias Disclist.Stats
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

  match _ do
    send_resp(conn, 200, "up and running")
  end
end
