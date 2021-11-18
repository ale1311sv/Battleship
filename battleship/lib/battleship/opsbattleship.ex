defmodule Ops.Battleship do
  @available_boats [5,4,3,3, 2]
  @table_size 10

  @type cell   :: {integer,integer}
  @type boat   :: [cell]
  @type state  :: { %{ atom: %{ boats: [boat], atom: [cell] }, atom: %{ atom: [boat], atom: [cell] }}, atom }
  @type player :: atom
  # FILL THIS PART @type player ::

  # cell = {X,Y} where X represents #row and Y represents #column
  # boat = [{X1,Y1}, ... , {Xn,Yn}]
  # state = {
  #           %{ player_i:
  #                       %{
  #                           boats: [boat_1,...,boat_m],
  #                           shots: [cell_1,...,cell_k]
  #                        }
  #             , :game_state
  #             }
  #         }
  # :game_state in [:setting, :p1, :p2, :game_over]
  @spec create_first_grid() :: [atom]
  def create_first_grid() do
    for _i <- 0 .. @table_size - 1, do:
      for _j <- 0 .. @table_size - 1, do:
        :water
  end

  # Function to check if requested cells can actually form a boat
  @spec is_it_a_boat?( cell, cell) :: boolean
  def is_it_a_boat?(cell1,celln), do: elem(cell1,0) == elem(celln,0) or elem(cell1,1) == elem(celln,1)
  
  # Function to check if LEGAL cells are vertical or horizontal aligned
  @spec cells_alignment( cell, cell ) :: atom
  def cells_alignment(cell1, celln) do
    cond do
      elem(cell1,0) == elem(celln, 0) -> :horizontal
      elem(cell1,1) == elem(celln, 1) -> :vertical
    end
  end

  # Function to set the length of the future boat
  @spec distance_btw_cells( cell, cell) :: integer
  def distance_btw_cells(cell1, celln) do
    abs( elem( cell1, 0) - elem( celln, 0) ) + abs( elem( cell1, 1) - elem( celln, 1) )
  end

  # Function to create a boat from cells WORKS ONLY FOR well defined wannabe boats
  @spec create_boat( cell, cell) :: boat
  def create_boat( cell1, celln) do
    case cells_alignment( cell1, celln) do
      :horizontal -> create_boat_horizontal( cell1, celln)
      :vertical   -> create_boat_vertical( cell1, celln )
    end
  end
  # Function which creats horizontal boats invoked by create_boat
  @spec create_boat_horizontal( cell, cell) :: boat
  def create_boat_horizontal( cell1, celln) do
    x = elem( cell1, 0) 
    n = distance_btw_cells( cell1, celln)
    y = [ elem( cell1, 1), elem( celln, 1) ] 
        |> Enum.sort()
        |> Enum.at(0)
    for j <- y .. (y + n), do: {x,j}
  end
  # Function which creats vertical boats invoked by create_boat
  @spec create_boat_vertical( cell, cell) :: boat
  def create_boat_vertical( cell1, celln) do
    y = elem( cell1, 1) 
    n = distance_btw_cells( cell1, celln)
    x = [ elem( cell1, 0), elem( celln, 0) ] 
        |> Enum.sort()
        |> Enum.at(0)
    for i <- x .. (x + y + n), do: {i,y}
  end
  

  # Boats that player1 can still use
  @spec boats_left_player(state, player) :: [integer]
  def boats_left_player({ %{ player1: %{ boats: list_boats, shots: _ }, player2: %{ boats: _, shots: _ } }, _ }, :player1) do
    @available_boats -- Enum.map(list_boats, &(length(&1)))
    |> Enum.sort()
  end
  # Boats that player2 can still use
  @spec boats_left_player(state, player) :: [integer]
  def boats_left_player({ %{ player1: %{ boats: list_boats, shots: _ } , player2: %{ boats: list_boats, shots: _ } }, _ }, :player2) do
    @available_boats -- Enum.map(list_boats, &(length(&1)))
    |> Enum.sort()
  end
  
  # Function to check if intended boat is available for player
  @spec is_boat_available?(boat, state, player) :: boolean
  def is_boat_available?(boat, state, player), do: Enum.member?( boats_left_player( state, player), length(boat) )
  
  # Functions to get the x-axis | y-axis coordinates of a boat
  @spec x_coordinates_boat(boat) :: [integer]
  def x_coordinates_boat(boat), do: Enum.map(boat, fn z -> elem(z,0) end) 
  @spec y_coordinates_boat(boat) :: [integer]
  def y_coordinates_boat(boat), do: Enum.map(boat, fn z -> elem(z,1) end) 
  
  # Functions to get the DIFFERENT x-axis | y-axis coordinates of a boat (treating them as mathematical sets)
  @spec x_coordinates_boat_uniq(boat) :: [integer]
  def x_coordinates_boat_uniq(boat), do: x_coordinates_boat(boat) |> Enum.uniq()
  @spec y_coordinates_boat_uniq(boat) :: [integer]
  def y_coordinates_boat_uniq(boat), do: y_coordinates_boat(boat) |> Enum.uniq()

  # Function to check if boat is well defined
  # now deprecated
  @spec is_boat_well_defined?(boat) :: boolean
  def is_boat_well_defined?(boat), do: length(x_coordinates_boat_uniq(boat)) == 1 or length(y_coordinates_boat_uniq(boat)) == 1

  # Function to see how LEGAL boat is oriented: horizontal or vertical
  @spec boat_orientation(boat) :: atom
  def boat_orientation(boat) do
    case x_coordinates_boat_uniq(boat) do
      1 -> :vertical
      _ -> :horizontal
    end
  end

  #Function to see how many cells a boat is long
  @spec length_boat(boat) :: integer
  def length_boat(boat), do: length(boat)

  # Function which returns if is possible to add any boat that player requests setting
  @spec can_i_set_boat?(boat, state, player) :: boolean
  def can_i_set_boat?(boat, state, player) do
    if (not is_boat_well_defined?(boat) ) or (not is_boat_available?(boat, state, player)) do
      false
    else
      true
    end
  end
end
