defmodule Subscribe.Core.Episode do
  use Ecto.Schema
  import Ecto.Changeset

  alias Subscribe.Core.Podcast

  schema "episodes" do
    field(:description, :string)
    field(:duration, :string)
    field(:enclosure_length, :integer)
    field(:enclosure_type, :string)
    field(:enclosure_url, :string)
    field(:guid, :string)
    field(:image, :string)
    field(:itunes_subtitle, :string)
    field(:itunes_summary, :string)
    field(:publication_date, Timex.Ecto.TimestampWithTimezone)
    field(:title, :string)

    belongs_to(:podcast, Podcast)

    timestamps()
  end

  @doc false
  def changeset(episode, attrs) do
    episode
    |> cast(attrs, [
      :title,
      :guid,
      :description,
      :duration,
      :itunes_summary,
      :itunes_subtitle,
      :enclosure_url,
      :enclosure_type,
      :enclosure_length,
      :publication_date,
      :image
    ])
    |> validate_required([
      :title,
      :guid,
      # :description,
      # :duration,
      # :itunes_summary,
      # :itunes_subtitle,
      :enclosure_url
      # :enclosure_type,
      # :enclosure_length,
      # :publication_date,
      # :image
    ])
  end
end
