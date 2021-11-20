defmodule Ops.Battleship do
  @available_boats [5,4,3,3, 2]
  @table_size 10

  @type cell   :: {integer,integer}
  @type boat   :: [cell]
  @type state  :: { %{ atom: %{ boats: [boat], atom: [cell] }, atom: %{ atom: [boat], atom: [cell] }}, atom, tuple }
  @type player :: atom

  @moduledoc """
   cell = {X,Y} where X represents row and Y represents column
   boat = [{X1,Y1}, ... , {Xn,Yn}]
   state = {
             %{ player_i:
                         %{
                             boats: [boat_1,...,boat_m],
                             shots: [cell_1,...,cell_k]
                          }
               , game_state , tuple_pids
               }
           }
   game_state in [:setting, :p1, :p2, :game_over]
   tuple_pids saves pids of player1 and player2
  """
  
  #PABLO
  
  @doc """ 
  Function to check if selected cells to set a boat are right 
  """
  @spec was_boat_selection_right?(cell, cell, integer) :: boolean
  def was_boat_selection_right?(cell1, celln, length_boat_selected), do: distance_btw_cells(cell1, celln) + 1 == length_boat_selected

  @doc """ 
  Function to add boat to the boats for player in state
  """
  @spec insert_boat_player(state, player, boat) :: state
  def insert_boat_player(state, player, boat) do
    player_content = update_boats_in_player(state, player, boat)
    new_players = Map.put( elem(state, 0), player, player_content)
    put_elem(state, 0, new_players)
  end

  @doc """
  Function to check if player set all boats already
  """
  @spec all_boats_in_player?(state, player) :: boolean
  def all_boats_in_player?(state, player), do: boats_left_player(state, player) == []

  @doc """ 
  Function to check if setting game state is done because all boats are set 
  """
  @spec all_boats_in?(state) :: boolean
  def all_boats_in?(state), do: all_boats_in_player?(state, :player1) and all_boats_in_player?(state, :player2)

  @doc """
  Function to add shot of player to state
  """
  def insert_shot_player(state, player, shot) do
    player_content = update_shots_in_player(state, player, shot)
    new_players = Map.put( elem(state, 0), player, player_content )
    put_elem(state, 0, new_players)
  end
  
  #SUPPORT FUNCTIONS FOR PABLO

  @doc """
  Boats that player1 can still use
  """
  @spec boats_left_player(state, player) :: [integer]
  def boats_left_player({ %{ player1: %{ boats: list_boats, shots: _ }, player2: %{ boats: _ , shots: _ } }, _ , _ }, :player1) do
    @available_boats -- Enum.map(list_boats, &(length(&1)))
    |> Enum.sort()
  end
  
  @doc """
  Boats that player2 can still use
  """
  @spec boats_left_player(state, player) :: [integer]
  def boats_left_player( { %{ player1: %{ boats: _ , shots: _ } , player2: %{ boats: list_boats, shots: _ } }, _ , _ }, :player2) do
    @available_boats -- Enum.map(list_boats, &(length(&1)))
    |> Enum.sort()
  end

  @doc """
  Function to set the length of the future boat
  """
  @spec distance_btw_cells( cell, cell) :: integer
  def distance_btw_cells(cell1, celln) do
    abs( elem( cell1, 0) - elem( celln, 0) ) + abs( elem( cell1, 1) - elem( celln, 1) )
  end




  #SERGIO
  @doc """
   Function which creates the original grid full of water
  """
  @spec create_first_grid() :: [[atom]]
  def create_first_grid() do
    { %{ player1: %{ boats: [], shots: [] }, player2: %{ boats: [], shots: [] } }, :setting, {} }
    |> paint_my_grid(:player1)
  end

  @doc """
   Function which creates the grid of boat and water cells
  """
  @spec paint_my_grid(state, player) :: [[atom]]
  def paint_my_grid(state, player) do
    boat_cells = get_boats_from_player(state, player) |> List.flatten()
    for i <- 0 .. @table_size - 1, do:
      for j <- 0 .. @table_size - 1, do:
        if Enum.member?(boat_cells, {i, j}), do: :boat, else: :water
  end


  # SUPPORT FUNCTIONS FOR SERGIO

  @doc """
  Function which returns the (i,j) cell of matrix
  """
  @spec access_cell([[atom]], integer, integer) :: atom
  def access_cell(matrix, i, j), do: Enum.at(matrix, i) |> Enum.at(j)

  @doc """
  Function to change the (i,j) cell of matrix to content
  """
  @spec update_cell_grid([[atom]], integer, integer, atom) :: [[atom]]
  def update_cell_grid(matrix, i, j, content), do: Enum.at(matrix, i) |> List.update_at(j, content)
  
  

  # MY OWN SUPPORT FUNCTIONS

  @doc """
  Function which updates boats list in player structure of state
  """
  @spec update_boats_in_player(state, player, boat) :: map
  def update_boats_in_player(state, player, boat) do
    add_boat = fn x -> get_boats_from_player(state, player) ++ [ x ] end
    elem(state, 0)
    |> Map.get(player) 
    |> Map.put(:boats, add_boat.(boat))
  end

  @doc """
  Function which updates shots list in player structure of state
  """
  @spec update_shots_in_player(state, player, cell) :: map
  def update_shots_in_player(state, player, shot) do
    add_shot = fn x -> get_shots_from_player(state, player) ++ [ x ] end
    elem(state, 0)
    |> Map.get(player)
    |> Map.put(:shots, add_shot.(shot))
  end

  @doc """
  Function to obtain the map containing players from state
  """
  @spec get_players_from_state(state) :: map
  def get_players_from_state(state), do: elem(state,0)

  @doc """
  Function to get specific player map from state
  """
  @spec get_player_from_state(state, player) :: %{ atom: [boat], atom: [cell] }
  def get_player_from_state(state, player), do: get_players_from_state(state) |> Map.get(player)

  @doc """
  Function to get the boats list of player
  """
  @spec get_boats_from_player(state, player) :: [boat]
  def get_boats_from_player(state, player), do: get_player_from_state(state, player) |> Map.get(:boats)

  @doc """
  Function to get the shots list of player
  """
  @spec get_shots_from_player(state, player) :: [cell]
  def get_shots_from_player(state, player), do: get_player_from_state(state, player) |> Map.get(:shots)
  


  # FUNCTIONS WHICH MIGHT BE USEFUL LATER

  @doc """
  Function to create a boat from cells WORKS ONLY FOR well defined wannabe boats
  """
  @spec create_boat( cell, cell) :: boat
  def create_boat( cell1, celln) do
    case cells_alignment( cell1, celln) do
      :horizontal -> create_boat_horizontal( cell1, celln)
      :vertical   -> create_boat_vertical( cell1, celln )
    end
  end

  @doc """
  Function which creats horizontal boats invoked by create_boat
  """
  @spec create_boat_horizontal( cell, cell) :: boat
  def create_boat_horizontal( cell1, celln) do
    x = elem( cell1, 0) 
    n = distance_btw_cells( cell1, celln)
    y = [ elem( cell1, 1), elem( celln, 1) ] 
        |> Enum.sort()
        |> Enum.at(0)
    for j <- y .. (y + n), do: {x,j}
  end

  @doc """
  Function which creats vertical boats invoked by create_boat
  """
  @spec create_boat_vertical( cell, cell) :: boat
  def create_boat_vertical( cell1, celln) do
    y = elem( cell1, 1) 
    n = distance_btw_cells( cell1, celln)
    x = [ elem( cell1, 0), elem( celln, 0) ] 
        |> Enum.sort()
        |> Enum.at(0)
    for i <- x .. (x + y + n), do: {i,y}
  end
  
  @doc """
  Function to check if requested cells can actually form a boat
  """
  @spec is_it_a_boat?( cell, cell) :: boolean
  def is_it_a_boat?(cell1,celln), do: elem(cell1,0) == elem(celln,0) or elem(cell1,1) == elem(celln,1)

  @doc """
  Function to check if LEGAL cells are vertical or horizontal aligned
  """
  @spec cells_alignment( cell, cell ) :: atom
  def cells_alignment(cell1, celln) do
    cond do
      elem(cell1,0) == elem(celln, 0) -> :horizontal
      elem(cell1,1) == elem(celln, 1) -> :vertical
    end
  end

  @doc """
  Function to check if intended boat is available for player
  """
  @spec is_boat_available?(boat, state, player) :: boolean
  def is_boat_available?(boat, state, player), do: Enum.member?( boats_left_player( state, player), length(boat) )

  @doc """ 
  Functions to get the x-axis | y-axis coordinates of a boat
  """
  @spec x_coordinates_boat(boat) :: [integer]
  def x_coordinates_boat(boat), do: Enum.map(boat, fn z -> elem(z,0) end) 
  @spec y_coordinates_boat(boat) :: [integer]
  def y_coordinates_boat(boat), do: Enum.map(boat, fn z -> elem(z,1) end) 

  @doc """
  Functions to get the DIFFERENT x-axis | y-axis coordinates of a boat (treating them as mathematical sets)
  """
  @spec x_coordinates_boat_uniq(boat) :: [integer]
  def x_coordinates_boat_uniq(boat), do: x_coordinates_boat(boat) |> Enum.uniq()
  @spec y_coordinates_boat_uniq(boat) :: [integer]
  def y_coordinates_boat_uniq(boat), do: y_coordinates_boat(boat) |> Enum.uniq()

  @doc """
  Function to check if boat is well defined now deprecated
  """
  @spec is_boat_well_defined?(boat) :: boolean
  def is_boat_well_defined?(boat), do: length(x_coordinates_boat_uniq(boat)) == 1 or length(y_coordinates_boat_uniq(boat)) == 1

  @doc """
  Function to see how LEGAL boat is oriented: horizontal or vertical
  """
  @spec boat_orientation(boat) :: atom
  def boat_orientation(boat) do
    case x_coordinates_boat_uniq(boat) do
      1 -> :vertical
      _ -> :horizontal
    end
  end

  @doc """
  Function to see how many cells a boat is long
  """
  @spec length_boat(boat) :: integer
  def length_boat(boat), do: length(boat)

  @doc """
  Function which returns if is possible to add any boat that player requests setting
  """
  @spec can_i_set_boat?(boat, state, player) :: boolean
  def can_i_set_boat?(boat, state, player) do
    if (not is_boat_well_defined?(boat) ) or (not is_boat_available?(boat, state, player)) do
      false
    else
      true
    end
  end

end
