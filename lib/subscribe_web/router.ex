defmodule SubscribeWeb.Router do
  use SubscribeWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", SubscribeWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/subscribe/config/*feed_url", SubscriptionController, :config)
    get("/subscribe/*feed_url", SubscriptionController, :subscribe)
  end

  # Other scopes may use custom stacks.
  # scope "/api", SubscribeWeb do
  #   pipe_through :api
  # end
end
