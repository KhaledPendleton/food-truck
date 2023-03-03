defmodule FoodTruck.Repo.Migrations.CreateOfferings do
  use Ecto.Migration

  def change do
    create table(:offerings) do
      add :content, :string

      timestamps([updated_at: false])
    end

    create unique_index(:offerings, :content)
  end
end
