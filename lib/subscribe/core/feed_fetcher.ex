defmodule Subscribe.Core.FeedFetcher do
  def fetch(url) do
    case HTTPoison.get(url, headers(), options()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
        {:ok, body, headers}

      {:ok, %HTTPoison.Response{status_code: 304}} ->
        :notmodified

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        raise url <> " Not found :("

      {:error, %HTTPoison.Error{reason: reason}} ->
        raise reason
    end
  end

  def headers do
    %{}
  end

  def options do
    [
      follow_redirect: true,
      ssl: [{:versions, [:"tlsv1.2"]}]
    ]
  end
end
