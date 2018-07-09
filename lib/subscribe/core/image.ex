defmodule Subscribe.Core.Image do
  defstruct [:url, :hash, :extension]

  alias Subscribe.Core.Image

  def create_from_url(url) do
    extension = url |> URI.parse() |> Map.get(:path) |> Path.extname()

    %Image{url: url, hash: hash(url), extension: extension}
  end

  def create_from_hash(hash) do
    meta =
      %Image{hash: hash}
      |> meta_path()
      |> File.read!()
      |> Poison.decode!()

    %Image{hash: hash, url: meta["url"], extension: meta["extension"]}
  end

  def generate_thumbnails(image) do
    image
    # |> Image.generate_thumbnail("180x180")
    # |> Image.generate_thumbnail("360x360")
    |> Image.generate_thumbnail("540x540")
  end

  def download(image) do
    File.mkdir_p(image_directory(image))
    %HTTPoison.Response{body: body} = HTTPoison.get!(image.url, [], follow_redirect: true)
    File.write!(original_path(image), body)

    File.write!(
      meta_path(image),
      Poison.encode!(%{
        url: image.url,
        extension: image.extension
      })
    )

    image
  end

  def generate_thumbnail(image, size \\ "180x180") do
    %Mogrify.Image{path: path} =
      image
      |> original_path()
      |> Mogrify.open()
      |> Mogrify.resize(size)
      |> Mogrify.format("jpg")
      |> Mogrify.custom("quality", "80")
      |> Mogrify.save()

    File.cp!(path, thumbnail_path(image, size))

    image
  end

  def meta_path(image) do
    [image_directory(image), "meta.json"] |> Path.join()
  end

  def original_path(image) do
    [image_directory(image), "original#{image.extension}"] |> Path.join()
  end

  def thumbnail_path(image, size) do
    [image_directory(image), "#{size}.jpg"] |> Path.join()
  end

  def thumbnail_url(image, size \\ "original") do
    SubscribeWeb.Router.Helpers.image_url(SubscribeWeb.Endpoint, :index, image.hash, size)
  end

  def base_directory() do
    Application.get_env(:subscribe, :image_path)
  end

  def image_directory(%Image{hash: hash}) do
    short_dir = String.slice(hash, 0..1)
    long_dir = String.slice(hash, 2..-1)
    [base_directory(), short_dir, long_dir] |> Path.join()
  end

  defp hash(string) do
    :crypto.hash(:md5, string) |> Base.encode16()
  end
end
