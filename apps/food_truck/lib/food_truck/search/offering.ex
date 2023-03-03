defmodule FoodTruck.Search.Offering do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias FoodTruck.Search

  schema "offerings" do
    field :content, :string
    many_to_many :locations, Search.Location, join_through: "locations_offerings"

    timestamps([updated_at: false])
  end

  @doc false
  def changeset(offering, attrs) do
    offering
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end

  @doc false
  def valid_offerings_query(potential_offerings) do
    from(
      o in "offerings",
      where: o.content in ^potential_offerings,
      select: o
    )
  end
end
