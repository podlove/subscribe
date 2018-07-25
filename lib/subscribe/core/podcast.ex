defmodule Subscribe.Core.Podcast do
  use Ecto.Schema
  import Ecto.Changeset

  alias Subscribe.Repo
  alias Subscribe.Core
  alias Subscribe.Core.{ImageUpdater, Episode, Podcast}

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

    has_many(:episodes, Episode)

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
         {:ok, podcast_fields, episodes} <- Subscribe.FeedParser.parse(xml),
         {:ok, podcast} <- refresh_podcast(podcast, podcast_fields) do
      refresh_episodes(podcast, episodes)

      podcast
    else
      {:error, :no_valid_feed} ->
        Logger.info("Could not fetch feed #{feed}. Reason: Not a valid feed")
        # just set to "temporary out of order" or similar; track since when stale
        Core.delete_podcast(podcast)
        :notfound

      {:error, reason} ->
        Logger.info("Could not fetch feed #{feed}. Reason: #{inspect(reason)}")
        # just set to "temporary out of order" or similar; track since when stale
        Core.delete_podcast(podcast)
        :notfound
    end
  end

  def refresh_podcast(podcast, updated_fields) do
    Core.update_podcast(podcast, %{
      title: updated_fields.title,
      subtitle: updated_fields.itunes_subtitle,
      description: updated_fields.itunes_summary,
      cover_url: updated_fields.image,
      type: "audio",
      format: "mp3",
      homepage_url: updated_fields.link,
      language: updated_fields.language
    })
  end

  def refresh_episodes(podcast, episodes) do
    for episode_fields <- episodes do
      # todo: gather whatever create/update errors occur
      Repo.get_by(Episode, guid: episode_fields.guid, podcast_id: podcast.id)
      |> case do
        nil -> Core.create_episode(podcast, episode_fields)
        episode -> Core.update_episode(episode, episode_fields)
      end
    end
  end
end
