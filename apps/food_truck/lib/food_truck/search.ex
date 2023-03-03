defmodule FoodTruck.Search do
  alias FoodTruck.Search
  alias FoodTruck.Repo

  @doc """
  Returns closest n trucks to location
  """
  def closest_locations(%Geo.Point{} = location, limit) when is_integer(limit) do
    Search.Location.closest_query(location, limit)
    |> Repo.all()
    |> Repo.preload(:company)
  end

  def locations_in_radius(%Geo.Point{} = center, radius_in_meters) do
    Search.Location.in_radius_query(center, radius_in_meters)
    |> Repo.all()
    |> Repo.preload(:company)
  end

  def locations_with_offering(%Search.Offering{} = offering) do
    offering = offering |> Repo.preload(locations: [:company, :offerings])
    offering.locations
  end

  def locations_with_offering(offering) when is_binary(offering) do
    offering =
      Search.Offering
      |> Repo.get_by(content: offering)
      |> Repo.preload(locations: [:company, :offerings])

    case offering do
      %Search.Offering{} -> offering.locations
      nil -> []
    end
  end

  def locations_by_owner(name) when is_binary(name) do
    company =
      Search.Company
      |> Repo.get_by(name: name)
      |> Repo.preload(locations: :offerings)

    company.locations
  end
end
