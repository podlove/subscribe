defmodule Subscribe.Core.Feed do
  def url_from_components(["https:" | components], params) do
    "https://" <> url_from_components(components, params)
  end

  def url_from_components(["http:" | components], params) do
    "http://" <> url_from_components(components, params)
  end

  def url_from_components(components, params) when params == %{} do
    Enum.join(components, "/")
  end

  def url_from_components(components, params) do
    Enum.join(components, "/") <> "?" <> URI.encode_query(params)
  end
end
