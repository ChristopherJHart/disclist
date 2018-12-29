defmodule Disclist.Web.HealthCheckup do
  use GenServer
  require Logger
  @checkup_time_ms 300_000
  @error_time_ms 5000
  @checkup_url System.get_env("CHECKUP_URL")
  @checkup_url || Mix.raise("No checkup url configured")

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    _ = Application.ensure_all_started(:inets)
    _ = Application.ensure_all_started(:ssl)
    {:ok, nil, @checkup_time_ms}
  end

  def handle_info(:timeout, state) do
    case :httpc.request(to_charlist(@checkup_url)) do
      {:ok, _} ->
        {:noreply, state, @checkup_time_ms}

      error ->
        Logger.error("Error checking health: #{inspect(error)}")
        {:noreply, state, @error_time_ms}
    end
  end
end
