defmodule FoodTruck.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :description, :string
      add :facility_type, :string, default: "truck"
      add :street, :string, default: "n/a"
      add :city, :string

      add :company_id, references(:companies, on_delete: :delete_all)

      timestamps()
    end

    execute("SELECT AddGeometryColumn('locations', 'coordinates', 4326, 'POINT', 2)")
    execute("CREATE INDEX location_coordinates_index on locations USING gist (coordinates)")

    create index(:locations, :street)
    create index(:locations, :facility_type)
  end
end
