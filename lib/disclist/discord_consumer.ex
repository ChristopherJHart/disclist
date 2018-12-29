defmodule Disclist.DiscordConsumer do
  use Nostrum.Consumer
  alias Nostrum.Api

  alias Disclist.{Craigslist, Craigslist.Query, Craigslist.Result}

  @id System.get_env("DISCORD_ID")
  @id ||
    Mix.raise("""
    No id configured
    """)

  @id String.to_integer(@id)

  @command_start "<@#{@id}>"

  @help_txt """
  ```md
  # Help

  ## ADD
  * add CITY URL - Add a city by a url

  ## PING
  * ping params - Send back whatever was sent in.
  ```
  """

  def start_link do
    Consumer.start_link(__MODULE__, name: __MODULE__)
  end

  def publish_result(%Query{channel_id: channel_id}, %Result{} = result) do
    case Api.create_message(channel_id, result_txt(result)) do
      {:ok, _} -> Craigslist.mark_result(result)
      error -> error
    end
  end

  def result_txt(result) do
    """
    #{result.title}
    URL: #{result.url}
    Price: #{result.price}
    Date: #{result.datetime}

    #{result.postingbody}

    #{List.first(result.image_urls)}
    """
  end

  def handle_event({:MESSAGE_CREATE, {%{author: %{id: @id}}}, _ws_state}) do
    :noop
  end

  def handle_event({:MESSAGE_CREATE, {msg}, _ws_state}) do
    case msg.content do
      @command_start <> command ->
        handle_command(String.trim(command), msg)

      _ ->
        :noop
    end
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end

  def handle_command("help", msg) do
    Api.create_message(msg.channel_id, @help_txt)
  end

  def handle_command("ping" <> extra, msg) do
    Api.create_message(msg.channel_id, "pong " <> extra)
  end

  def handle_command("list" <> _, msg) do
    urls =
      Craigslist.list_queries()
      |> Enum.filter(fn %{channel_id: channel_id} ->
        channel_id == msg.channel_id
      end)
      |> Enum.map(fn query ->
        Craigslist.url(query.city) <> "/search/sss" <> "?" <> query.query_string
      end)
      |> Enum.join("\n")

    Api.create_message(msg.channel_id, "Currently tracked urls: #{urls}")
  end

  def handle_command("add" <> _ = add_command, msg) do
    case String.split(add_command, " ") do
      ["add", "http" <> _ = url] ->
        %{host: host, query: query_string} = URI.parse(url)
        [city, "craigslist", "org"] = String.split(host, ".")

        params = %{
          city: city,
          query_string: query_string,
          channel_id: msg.channel_id
        }

        case Craigslist.new_query(params) do
          {:ok, %Query{}} ->
            url = Craigslist.url(city) <> "/search/sss" <> "?" <> query_string
            Api.create_message(msg.channel_id, "Added #{url}")
            Craigslist.QueryLoader.checkup()

          {:error, changeset} ->
            errors = for {key, {msg, _}} <- changeset.errors, do: "`#{key}` => #{msg}"

            Api.create_message(
              msg.channel_id,
              ["Error adding city" | errors] |> Enum.join("\n\t")
            )
        end

      ["add" | _] ->
        Api.create_message(
          msg.channel_id,
          "USAGE: `add url - Add a url to scrape`"
        )
    end
  end

  def handle_command(command, msg), do: error(command, msg)

  def error(command, msg) do
    Api.create_message(msg.channel_id, "Unhandled command: #{inspect(command)}")
  end
end
