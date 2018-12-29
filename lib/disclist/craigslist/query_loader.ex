defmodule Disclist.Craigslist.QueryLoader do
  use GenServer
  alias Disclist.{Craigslist, Craigslist.ScraperSupervisor}
  @checkup_time 60_000

  def checkup do
    send(__MODULE__, :timeout)
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:ok, nil, 0}
  end

  def handle_info(:timeout, state) do
    for child <- Craigslist.list_queries() do
      ScraperSupervisor.start_child(child)
    end

    {:noreply, state, @checkup_time}
  end
end
