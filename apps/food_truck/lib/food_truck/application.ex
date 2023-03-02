defmodule FoodTruck.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      FoodTruck.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: FoodTruck.PubSub},
      # Start Finch
      {Finch, name: FoodTruck.Finch}
      # Start a worker by calling: FoodTruck.Worker.start_link(arg)
      # {FoodTruck.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: FoodTruck.Supervisor)
  end
end
