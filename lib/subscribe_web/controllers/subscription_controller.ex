defmodule SubscribeWeb.SubscriptionController do
  use SubscribeWeb, :controller
  alias Subscribe.Repo
  alias Subscribe.Core
  alias Subscribe.Core.Podcast
  alias Subscribe.Core.Image

  import Subscribe.Core.Feed, only: [url_from_components: 2]

  def subscribe(conn, params) do
    feed_url = get_feed_url(params)
    podcast = get_podcast(feed_url)

    case podcast.podcast do
      %Podcast{} ->
        colors = dominant_colors(podcast.podcast)

        main_color =
          with color when not is_nil(color) <- List.first(colors) do
            color
          else
            _ -> "rgb(0,0,0)"
          end

        gradient =
          with color when not is_nil(color) <- List.first(colors),
               {:ok, main_color} <- color |> CssColors.parse() do
            %{
              from: main_color |> to_string(),
              to: CssColors.darken(main_color, 0.1) |> to_string()
            }
          else
            _ ->
              %{
                from: "rgb(0,0,0)",
                to: "rgb(25,25,25)"
              }
          end

        render(conn, "subscribe.html",
          podcast: podcast.podcast,
          button_opts: podcast.button_opts,
          colors: colors,
          gradient: gradient,
          main_color: main_color
        )

      _ ->
        render(conn, "error.html", url: feed_url)
    end
  end

  def config(conn, params) do
    podcast = get_podcast(params)
    render(conn, "config.json", button_opts: podcast.button_opts)
  end

  def get_feed_url(params = %{"feed_url" => feed_components}) do
    feed_params = Map.delete(params, "feed_url")
    url_from_components(feed_components, feed_params)
  end

  defp get_podcast(feed_url) do
    podcast = fetch_podcast(feed_url) || init_podcast(feed_url)

    %{
      podcast: podcast,
      button_opts: button_opts(podcast)
    }
  end

  defp fetch_podcast(feed_url) do
    Repo.get_by(Podcast, feed: feed_url)
  end

  defp init_podcast(feed_url) do
    case Core.create_podcast(%{feed: feed_url}) do
      {:ok, %Podcast{} = podcast} ->
        Podcast.refresh_data(podcast)

      {:error, %Ecto.Changeset{}} ->
        nil
    end
  end

  def dominant_colors(%Podcast{} = podcast) do
    image = Image.create_from_url(podcast.cover_url)
    size = "540x540"
    path = Image.thumbnail_path(image, size)

    if File.exists?(path) do
      path
      |> OcvPhotoAnalyzer.analyze([:dominant])
      |> Map.get(:dominant)
      |> Enum.map(fn c -> "rgb(#{c.r}, #{c.g}, #{c.b})" end)
    else
      []
    end
  end

  defp button_opts(%Podcast{} = podcast) do
    image = Image.create_from_url(podcast.cover_url)
    size = "540x540"

    cover_url =
      if File.exists?(Image.thumbnail_path(image, size)) do
        Image.thumbnail_url(image, size)
      else
        podcast.cover_url
      end

    %{
      title: podcast.title,
      subtitle: podcast.subtitle,
      description: podcast.description,
      cover: cover_url,
      feeds: [
        %{
          type: podcast.type,
          format: podcast.format,
          url: canonical_feed_url(podcast.feed)
        }
      ],
      language: language(podcast)
    }
  end

  defp button_opts(_) do
    %{}
  end

  defp canonical_feed_url(url) when is_binary(url) do
    url
    |> URI.parse()
    |> canonical_feed_url
  end

  defp canonical_feed_url(%URI{path: path, host: nil}) do
    canonical_feed_url("//#{path}")
  end

  defp canonical_feed_url(uri = %URI{}) do
    URI.to_string(uri)
  end

  defp language(%{language: language}) do
    language
    |> String.split("-")
    |> List.first()
  end

  defp language(_), do: "en"
end
