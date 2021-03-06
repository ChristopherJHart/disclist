defmodule Disclist.Craigslist.QueryScraper do
  use GenServer
  require Logger
  alias Disclist.{DiscordConsumer, Craigslist, Craigslist.Query}
  @checkup_ms 900_000

  def child_spec([%Query{} = query]) do
    %{
      id: {__MODULE__, query.id},
      start: {__MODULE__, :start_link, [query]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(%Query{} = query) do
    GenServer.start_link(__MODULE__, query)
  end

  def init(query) do
    {:ok, query, 0}
  end

  def handle_info(:timeout, query) do
    {:noreply, query, {:continue, Craigslist.search(query.city, query.query_string)}}
  end

  def handle_continue([result | rest], query) do
    if Craigslist.get_result(data_id: result.data_id) do
      Logger.info("Already requested: #{result.data_id}")
      {:noreply, query, {:continue, rest}}
    else
      params = Map.merge(result, Craigslist.result(result.url))

      case Craigslist.new_result(params) do
        {:ok, result} ->
          DiscordConsumer.publish_result(query, result)

        changeset ->
          Logger.error("Failed to get result: #{inspect(changeset)}")
      end

      {:noreply, query, {:continue, rest}}
    end
  end

  def handle_continue([], query) do
    checkup = fuzz(@checkup_ms)
    from_now = Timex.from_now(Timex.shift(DateTime.utc_now(), milliseconds: checkup))
    Logger.info("Will checkup on #{inspect(query)} again #{from_now}")
    {:noreply, query, checkup}
  end

  def fuzz(millis), do: millis + :rand.uniform(60_500)
end
