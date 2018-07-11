defmodule Subscribe.Core.Podcast do
  use Ecto.Schema
  import Ecto.Changeset
  alias Subscribe.Core
  alias Subscribe.Core.{ImageUpdater, Podcast}

  require Logger

  schema "podcasts" do
    field(:cover_url, :string)
    field(:description, :string)
    field(:feed, :string)
    field(:format, :string)
    field(:itunes_url, :string)
    field(:subtitle, :string)
    field(:title, :string)
    field(:type, :string)
    field(:homepage_url, :string)
    field(:language, :string)

    timestamps()
  end

  @doc false
  def changeset(podcast, attrs) do
    podcast
    |> cast(attrs, [
      # todo: to suffix url columns with "_url" or not? this is the question
      :feed,
      :title,
      :subtitle,
      :description,
      :cover_url,
      :type,
      :format,
      :itunes_url,
      :homepage_url,
      :language
    ])
    |> validate_required([:feed])
    |> unique_constraint(:feed)
    |> upadte_image_cache_on_cover_change()
  end

  def upadte_image_cache_on_cover_change(changeset) do
    set_image_cache(changeset, get_change(changeset, :cover_url))
  end

  defp set_image_cache(changeset, nil) do
    changeset
  end

  defp set_image_cache(changeset, new_cover_url) do
    ImageUpdater.fetch_url(new_cover_url)

    changeset
  end

  def refresh_data(podcast = %Podcast{feed: feed}) do
    with {:ok, xml, _headers} <- Subscribe.Core.FeedFetcher.fetch(feed),
         {:ok, fields} <- Subscribe.FeedParser.parse(xml) do
      {:ok, podcast} =
        Core.update_podcast(podcast, %{
          title: fields.title,
          subtitle: fields.itunes_subtitle,
          description: fields.itunes_summary,
          cover_url: fields.image,
          type: "audio",
          format: "mp3",
          homepage_url: fields.link,
          language: fields.language
        })

      podcast
    else
      {:error, :no_valid_feed} ->
        Logger.info("Could not fetch feed #{feed}. Reason: Not a valid feed")
        Core.delete_podcast(podcast)
        :notfound

      {:error, reason} ->
        Logger.info("Could not fetch feed #{feed}. Reason: #{inspect(reason)}")
        Core.delete_podcast(podcast)
        :notfound
    end
  end
end
