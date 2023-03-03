# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     FoodTruck.Repo.insert!(%FoodTruck.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# ###########
# Helpers
# ###########

conversion_to_row = fn
  {:ok, row} -> row
  {:error, _} -> nil
end

nil_filter = fn
  nil -> false
  _ -> true
end

offerings_cell_to_list = fn
  content when is_binary(content) ->
    content
    |> String.split([":", "&"], trim: true)
    |> Stream.map(&String.trim/1)
    |> Enum.filter(nil_filter)
end

potential_offerings = fn offering ->
  offering
  |> String.downcase()
  |> offerings_cell_to_list.()
end

build_offering = fn offering ->
  %{content: offering}
end

build_location = fn %{facility_type: ft, offerings: o, loc_description: ld, address: %{street: s, city: c}, coordinates: cd} ->
  %{
    description: "#{o}\n#{ld}",
    facility_type: ft,
    coordinates: cd,
    street: s,
    city: c,
    potential_offerings: potential_offerings.(o)
  }
end

reduce_location_to_company = fn
  location, company when company == %{} ->
    %{name: location.name, locations: [build_location.(location)]}

  location, company ->
    %{company | locations: [build_location.(location) | company.locations]}
end

reduce_locations_to_company = fn location_chunk ->
  Enum.reduce(location_chunk, %{}, reduce_location_to_company)
end

validate_offering = fn val ->
  case IO.gets("Keep offering \"#{val}\"? [Ynm] ") do
    "Y\n" -> val
    "n\n" -> nil
    "m\n" ->
      new_value =
        "To what would you like to change the value? "
        |> IO.gets()
        |> String.replace_trailing("\n", "")

      new_value
  end
end

extract_location_from_row = fn
  [_, n, f, _, ld, s, _, _, _, _, _, o, _, _, lat, lon, _, _, _, _, _, _, _, _, _, _, _, _, _] ->
    {lat, _} = Float.parse(lat)
    {lon, _} = Float.parse(lon)

    %{
      name: n,
      facility_type: f,
      offerings: o,
      loc_description: ld,
      address: %{street: s, city: "San Francisco"},
      coordinates: %{lat: lat, lon: lon}
    }
end

file_stream = fn filename ->
  "#{__DIR__}/#{filename}"
  |> File.stream!()
  |> CSV.decode()
  |> Stream.map(conversion_to_row)
  |> Stream.filter(nil_filter)
end

process_offerings = fn location_data_stream ->
  location_data_stream
  |> Stream.map(&(&1.offerings))
  |> Stream.map(&String.downcase/1)
  |> Stream.uniq()
  |> Stream.map(offerings_cell_to_list)
  |> Enum.to_list()
  |> List.flatten()
  |> Stream.uniq()
  |> Stream.map(validate_offering)
  |> Stream.uniq()
  |> Stream.filter(nil_filter)
  |> Enum.map(build_offering)
end

process_companies = fn location_data_stream ->
  location_data_stream
  |> Enum.sort(&(&1.name > &2.name))
  |> Stream.chunk_by(&(&1.name))
  |> Enum.map(reduce_locations_to_company)
end

process_file = fn file_stream ->
  locations =
    file_stream
    |> Stream.map(extract_location_from_row)

  {process_companies.(locations), process_offerings.(locations)}
end

# ###########
# Execution
# ###########

{companies, offerings} =
  "food-truck-seed-data.csv"
  |> file_stream.()
  |> process_file.()

for offering <- offerings do
  %FoodTruck.Search.Offering{}
  |> FoodTruck.Search.Offering.changeset(offering)
  |> FoodTruck.Repo.insert!()
end

for company <- companies do
  persisted_company =
    %FoodTruck.Search.Company{}
    |> FoodTruck.Search.Company.changeset(company)
    |> FoodTruck.Repo.insert!()

  for location <- company.locations do
    persisted_location =
      %FoodTruck.Search.Location{}
      |> FoodTruck.Search.Location.changeset(location)
      |> Ecto.Changeset.put_assoc(:company, persisted_company)
      |> FoodTruck.Repo.insert!()

    valid_offerings =
      FoodTruck.Repo.all(
        FoodTruck.Search.Offering.valid_offerings_query(location.potential_offerings)
      )

    for offering <- valid_offerings do
      attrs = %{
        location_id: persisted_location.id,
        offering_id: offering.id
      }

      %FoodTruck.Search.LocationOffering{}
      |> FoodTruck.Search.LocationOffering.changeset(attrs)
      |> FoodTruck.Repo.insert!()
    end
  end
end
