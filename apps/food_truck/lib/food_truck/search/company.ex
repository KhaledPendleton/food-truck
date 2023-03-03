defmodule FoodTruck.Search.Company do
  use Ecto.Schema
  import Ecto.Changeset
  alias FoodTruck.Search

  schema "companies" do
    field :name, :string

    has_many :locations, Search.Location

    timestamps()
  end

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> cast_assoc(:locations, with: &Search.Location.changeset/2)
  end
end
