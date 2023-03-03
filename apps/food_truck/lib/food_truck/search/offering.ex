defmodule FoodTruck.Search.Offering do
  use Ecto.Schema
  import Ecto.Changeset

  schema "offerings" do
    field :content, :string

    timestamps([updated_at: false])
  end

  @doc false
  def changeset(offering, attrs) do
    offering
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
