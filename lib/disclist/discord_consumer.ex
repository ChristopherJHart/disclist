defmodule Disclist.DiscordConsumer do
  use Nostrum.Consumer
  alias Nostrum.Api

  alias Disclist.{Craigslist, Craigslist.Query, Craigslist.Result}
  alias Disclist.Web.HealthCheckup

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
  * add URL - Add a city by a url

  ## DELETE
  * delete URL - Delete a city from being scraped

  ## PING
  * ping params - Send back whatever was sent in.

  ## CHECKUP
  * checkup - Self checkup
  ```
  """

  def start_link do
    Consumer.start_link(__MODULE__, name: __MODULE__)
  end

  def publish_result(%Query{channel_id: channel_id}, %Result{} = result) do
    import Nostrum.Struct.Embed

    embed =
      %Nostrum.Struct.Embed{}
      |> put_title(result.title || "*No title*")
      |> put_description(to_string(result.postingbody || "*No post body*"))

    embed =
      if result.url do
        put_url(embed, result.url)
      else
        embed
      end

    embed =
      embed
      |> put_field("Price", to_string(result.price || "*No price*"))
      |> put_field("Posted", Timex.from_now(result.datetime || DateTime.utc_now()))

    embed =
      if image_url = List.first(result.image_urls) do
        put_image(embed, image_url)
      else
        embed
      end

    case Api.create_message(channel_id, embed: embed) do
      {:ok, _} -> Craigslist.mark_result(result)
      error -> error
    end
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

  def handle_command("stats" <> _, msg) do
    unique_results = Disclist.Stats.count_total_results()
    unique_queries = Disclist.Stats.count_total_queries()
    unique_channels = Disclist.Stats.count_total_channels()

    data = """
    Currently #{unique_results} unique Craigslist posts scraped by #{unique_queries} 
    unique queries published to #{unique_channels} unique Discord channels.
    """

    Api.create_message(msg.channel_id, data)
  end

  def handle_command("checkup" <> _, msg) do
    case HealthCheckup.checkup() do
      {:ok, _} -> Api.create_message(msg.channel_id, "ok")
      {:error, _} -> Api.create_message(msg.channel_id, "error")
    end
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

  def handle_command("delete" <> _ = delete_command, msg) do
    case String.split(delete_command, " ") do
      ["delete", "http" <> _ = url] ->
        %{host: host, query: query_string} = URI.parse(url)
        [city, "craigslist", "org"] = String.split(host, ".")

        if query =
             Craigslist.get_query_by_city_and_query_string(msg.channel_id, city, query_string) do
          Craigslist.delete_query!(query)
          Api.create_message(msg.channel_id, "#{url} deleted")
        else
          Api.create_message(msg.channel_id, "Could not find #{url}")
        end

      ["delete" | _] ->
        Api.create_message(
          msg.channel_id,
          "USAGE: `delete URL` - delete a url from being scraped"
        )
    end
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
          "USAGE: `add URL` - Add a url to scrape"
        )
    end
  end

  def handle_command(command, msg), do: error(command, msg)

  def error(command, msg) do
    Api.create_message(msg.channel_id, "Unhandled command: #{inspect(command)}")
  end
end
