defmodule FoodTruck.Search.LocationOffering do
  use Ecto.Schema
  alias FoodTruck.Search

  schema "locations_offerings" do
    belongs_to :location, Search.Location
    belongs_to :offering, Search.Offering
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:location_id, :offering_id])
    |> Ecto.Changeset.validate_required([:location_id, :offering_id])
  end
end
