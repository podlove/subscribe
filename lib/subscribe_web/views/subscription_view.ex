defmodule SubscribeWeb.SubscriptionView do
  use SubscribeWeb, :view

  def render("config.json", %{button_opts: button_opts}) do
    button_opts
  end

  @doc """
  Render pretty URL without schema and trailing slash
  """
  def pretty_url(url) when is_binary(url) do
    url
    |> URI.parse()
    |> pretty_url()
  end

  def pretty_url(%URI{host: host, path: "/"}) do
    host
  end

  def pretty_url(%URI{host: host, path: nil}) do
    host
  end

  def pretty_url(%URI{host: host, path: path}) do
    host <> path
  end

  def twitter_share_url(url) do
    "https://twitter.com/share?" <> URI.encode_query(%{url: url})
  end

  def facebook_share_url(url) do
    "https://www.facebook.com/sharer/sharer.php?" <> URI.encode_query(%{u: url})
  end
end
