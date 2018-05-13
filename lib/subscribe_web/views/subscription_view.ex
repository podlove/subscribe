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
end
