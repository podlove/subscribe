defmodule SubscribeWeb.PageController do
  use SubscribeWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
