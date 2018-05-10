defmodule Subscribe.Repo.Migrations.CreatePodcasts do
  use Ecto.Migration

  def change do
    create table(:podcasts) do
      add(:feed, :text)
      add(:title, :text)
      add(:subtitle, :text)
      add(:description, :text)
      add(:cover_url, :text)
      add(:type, :string)
      add(:format, :string)
      add(:itunes_url, :text)

      timestamps()
    end

    create(unique_index(:podcasts, :feed))
  end
end
