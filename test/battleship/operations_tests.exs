defmodule TestOperations do
  use ExUnit.Case
  alias Battleship.Operations
  doctest Operations

  test "is_boat_available?(boat, located_boats, available_boats)" do
    boat1 = [{2,2}]
    located_boats = [{3,4}, {3,5}]
    IO.puts "boat = #{boat1}"
    Battleship.Operations.is_boat_available?(boat1, )
