defmodule SubscribeWeb.PageController do
  use SubscribeWeb, :controller

  def index(conn, %{"feed_url" => feed_url}) do
    redirect(conn, to: "/#{feed_url}")
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
