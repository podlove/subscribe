defmodule SubscribeWeb.SubscriptionView do
  use SubscribeWeb, :view

  def render("config.json", %{button_opts: button_opts}) do
    button_opts
  end
end
