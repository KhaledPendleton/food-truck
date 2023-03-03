defmodule FoodTruck.Repo.Migrations.CreateLocationOffering do
  use Ecto.Migration

  def change do
    create table(:locations_offerings) do
      add :location_id, references(:locations)
      add :offering_id, references(:offerings)
    end

    create unique_index(:locations_offerings, [:location_id, :offering_id])
  end
end
