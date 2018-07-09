defmodule SubscribeWeb.ImageController do
  use SubscribeWeb, :controller

  alias Subscribe.Core.Image

  def index(conn, %{"hash" => hash, "size" => size}) do
    image = Image.create_from_hash(hash)
    path = Image.thumbnail_path(image, size)
    etag = file_md5(path)

    if stale?(conn, etag) do
      conn
      |> put_resp_content_type("image/jpeg")
      |> put_resp_header("etag", etag)
      |> send_resp(200, File.read!(path))
    else
      send_resp(conn, 304, "")
    end
  end

  # adapted from phoenix_etag package
  defp stale?(conn, etag) do
    none_match =
      conn
      |> get_req_header("if-none-match")
      |> List.first()

    if none_match do
      none_match?(none_match, etag)
    else
      true
    end
  end

  defp none_match?(none_match, etag) do
    if none_match && etag do
      none_match = Plug.Conn.Utils.list(none_match)
      not (etag in none_match) and not ("*" in none_match)
    else
      false
    end
  end

  defp file_md5(path) do
    path |> File.read!() |> (fn content -> :crypto.hash(:md5, content) end).() |> Base.encode16()
  end
end
