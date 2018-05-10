defmodule Subscribe.Core.Podcast do
  use Ecto.Schema
  import Ecto.Changeset

  schema "podcasts" do
    field(:cover_url, :string)
    field(:description, :string)
    field(:feed, :string)
    field(:format, :string)
    field(:itunes_url, :string)
    field(:subtitle, :string)
    field(:title, :string)
    field(:type, :string)

    timestamps()
  end

  @doc false
  def changeset(podcast, attrs) do
    podcast
    |> cast(attrs, [
      :feed,
      :title,
      :subtitle,
      :description,
      :cover_url,
      :type,
      :format,
      :itunes_url
    ])
    |> validate_required([
      :feed,
      :title,
      :subtitle,
      :description,
      :cover_url,
      :type,
      :format,
      :itunes_url
    ])
  end
end
