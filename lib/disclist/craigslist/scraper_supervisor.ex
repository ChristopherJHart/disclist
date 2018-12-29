defmodule Disclist.Craigslist.ScraperSupervisor do
  use Supervisor
  alias Disclist.{Craigslist.ScraperSupervisor, Craigslist.QueryScraper}

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    Supervisor.init([], strategy: :one_for_one)
  end

  def list_children do
    Supervisor.which_children(ScraperSupervisor)
  end

  def start_child(query) do
    Supervisor.start_child(__MODULE__, {QueryScraper, [query]})
  end
end
