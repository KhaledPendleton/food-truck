defmodule FoodTruck.Search.Location do
  use Ecto.Schema

  import Ecto.{Changeset, Query}
  import Geo.PostGIS

  alias FoodTruck.Search

  schema "locations" do
    field :description, :string
    field :facility_type, :string, default: "truck"
    field :street, :string, default: "n/a"
    field :city, :string
    field :coordinates, Geo.PostGIS.Geometry

    belongs_to :company, Search.Company
    many_to_many :offerings, Search.Offering, join_through: "locations_offerings"

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:description, :facility_type, :street, :city])
    |> cast_coordinates(attrs)
    |> validate_required([:description, :facility_type, :street, :city, :coordinates])
  end

  @doc false
  defp cast_coordinates(changeset, attrs) do
    %{lat: lat, lon: lon} = attrs.coordinates
    put_change(changeset, :coordinates, %Geo.Point{coordinates: {lon, lat}, srid: 4326})
  end

  @doc false
  def closest_query(%Geo.Point{} = location, limit) do
    from(
      l in __MODULE__,
      limit: ^limit,
      order_by: st_distance(l.coordinates, ^location)
    )
  end

  @doc false
  def in_radius_query(%Geo.Point{} = center, radius_in_meters) do
    from(
      l in __MODULE__,
      where: st_dwithin_in_meters(l.coordinates, ^center, ^radius_in_meters)
    )
  end
end
