defmodule SubscribeWeb.SubscriptionController do
  use SubscribeWeb, :controller
  alias Subscribe.Core
  alias Subscribe.Core.Podcast
  import Subscribe.Core.Feed, only: [url_from_components: 2]

  def subscribe(conn, params = %{"feed_url" => feed_components}) do
    feed_params = Map.delete(params, "feed_url")
    feed_url = url_from_components(feed_components, feed_params)

    # todo: check if feed is known before adding a new one

    podcast =
      case Core.create_podcast(%{feed: feed_url}) do
        {:ok, %Podcast{} = podcast} ->
          Podcast.refresh_data(podcast)

        {:error, %Ecto.Changeset{} = changeset} ->
          # assume it's because it already exists
          Subscribe.Repo.get_by!(Podcast, feed: feed_url)
      end

    button_opts = %{
      title: podcast.title,
      subtitle: podcast.subtitle,
      description: podcast.description,
      cover: podcast.cover_url,
      feeds: [
        %{
          type: podcast.type,
          format: podcast.format,
          url: feed_url
        }
      ]
    }

    render(conn, "subscribe.html", podcast: podcast, button_opts: button_opts)
  end
end
