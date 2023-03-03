defmodule FoodTruck.Search.Location do
  use Ecto.Schema
  import Ecto.Changeset
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

  defp cast_coordinates(changeset, attrs) do
    %{lat: lat, lon: lon} = attrs.coordinates
    put_change(changeset, :coordinates, %Geo.Point{coordinates: {lon, lat}, srid: 4326})
  end
end
