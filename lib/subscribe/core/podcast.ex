defmodule Subscribe.Core.Podcast do
  use Ecto.Schema
  import Ecto.Changeset
  alias Subscribe.Core
  alias Subscribe.Core.Podcast

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
      :homepage_url
    ])
    |> validate_required([:feed])
    |> unique_constraint(:feed)
  end

  def refresh_data(podcast = %Podcast{feed: feed}) do
    case Subscribe.Core.FeedFetcher.fetch(feed) do
      {:ok, xml, _headers} ->
        Subscribe.Core.FeedFetcher.fetch(feed)
        fields = Subscribe.FeedParser.parse(xml)

        {:ok, podcast} =
          Core.update_podcast(podcast, %{
            title: fields.title,
            subtitle: fields.itunes_subtitle,
            description: fields.itunes_summary,
            cover_url: fields.image,
            type: "audio",
            format: "mp3",
            homepage_url: fields.link
          })

        podcast

      {:error, _reason} ->
        Core.delete_podcast(podcast)

        :notfound
    end
  end
end
