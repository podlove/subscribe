defmodule SubscribeWeb.SubscriptionController do
  use SubscribeWeb, :controller
  alias Subscribe.Repo
  alias Subscribe.Core
  alias Subscribe.Core.Podcast
  import Subscribe.Core.Feed, only: [url_from_components: 2]

  def subscribe(conn, params) do
    podcast = get_podcast(params)

    case podcast.podcast do
      %Podcast{} ->
        render(conn, "subscribe.html", podcast: podcast.podcast, button_opts: podcast.button_opts)

      _ ->
        render(conn, "error.html")
    end
  end

  def config(conn, params) do
    podcast = get_podcast(params)
    render(conn, "config.json", button_opts: podcast.button_opts)
  end

  defp get_podcast(params = %{"feed_url" => feed_components}) do
    feed_params = Map.delete(params, "feed_url")
    feed_url = url_from_components(feed_components, feed_params)

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

  defp button_opts(%Podcast{} = podcast) do
    %{
      title: podcast.title,
      subtitle: podcast.subtitle,
      description: podcast.description,
      cover: podcast.cover_url,
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

  def canonical_feed_url(url) when is_binary(url) do
    url
    |> URI.parse()
    |> canonical_feed_url
  end

  def canonical_feed_url(%URI{path: path, host: nil}) do
    canonical_feed_url("//#{path}")
  end

  def canonical_feed_url(uri = %URI{}) do
    URI.to_string(uri)
  end

  defp language(%{language: language}) do
    language
    |> String.split("-")
    |> List.first()
  end

  defp language(_), do: "en"

  defp button_opts(_) do
    %{}
  end
end
