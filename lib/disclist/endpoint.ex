defmodule Disclist.Endpoint do
  use Supervisor
  alias Disclist.Router
  require Logger

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    endpoint_config = 
      Application.get_env(:disclist, __MODULE__, [])
      |> Keyword.merge(args)

    children = if port = endpoint_config[:port] do
      port = String.to_integer(port)
      host = endpoint_config[:host] || "localhost"
      Logger.info "Starting endpoing on http://#{host}:#{port}"
      [
        {Plug.Cowboy, scheme: :http, plug: Router, options: [port: port]}
      ]
    else
      []
    end
    Supervisor.init(children, [strategy: :one_for_one])
  end
end