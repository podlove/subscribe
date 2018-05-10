defmodule SubscribeWeb.SubscriptionController do
  use SubscribeWeb, :controller
  import Subscribe.Core.Feed, only: [url_from_components: 2]

  def subscribe(conn, params = %{"feed_url" => feed_components}) do
    # IO.inspect(feed_components)
    feed_params = Map.delete(params, "feed_url")
    feed_url = url_from_components(feed_components, feed_params)

    render(conn, "subscribe.html", feed: feed_url)
  end
end
