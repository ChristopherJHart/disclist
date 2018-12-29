defmodule Disclist.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      Disclist.Repo,
      Disclist.DiscordConsumer,
      Disclist.Craigslist.ScraperSupervisor,
      Disclist.Craigslist.QueryLoader,
      Disclist.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Disclist.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
