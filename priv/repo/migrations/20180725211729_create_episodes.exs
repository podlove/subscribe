defmodule Subscribe.Repo.Migrations.CreateEpisodes do
  use Ecto.Migration

  def change do
    create table(:episodes) do
      add(:podcast_id, references(:podcasts, on_delete: :nothing))
      add(:title, :text)
      add(:publication_date, :timestamptz)
      add(:guid, :string)
      add(:enclosure_url, :text)
      add(:enclosure_type, :string)
      add(:enclosure_length, :integer)
      add(:duration, :string)
      add(:description, :text)
      add(:itunes_summary, :text)
      add(:itunes_subtitle, :text)
      add(:image, :text)

      timestamps()
    end

    create(index(:episodes, [:podcast_id]))
  end
end
