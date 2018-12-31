defmodule Disclist.Stats do
  alias Disclist.{Repo, Craigslist.Result, Craigslist.Query}
  import Ecto.Query, warn: false

  def count_total_results do
    Repo.one(from(r in Result, select: count(r.id)))
  end

  def count_total_queries do
    Repo.one(from(q in Query, select: count(q.id)))
  end

  def count_total_channels do
    Repo.one(from(q in Query, select: count(q.channel_id, :distinct)))
  end
end
