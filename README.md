# FoodTruck.Umbrella

I'm scaffolding a data entry tool for a social network that tracks food truck activity.

This project contains:
1. A database seeder that populates the database with data from a file. The values of data in the file can be overwritten by the seeder caller.
2. A command line interface for fetching the closest n food trucks, food trucks within x radius, trucks with certain offerings, or by owner.

Start server with command "iex -S mix". Search function definitions can be found in './apps/food_truck/lib/food_truck/search.ex'