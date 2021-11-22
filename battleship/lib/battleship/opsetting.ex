defmodule Battleship.Opsetting do
  
  @type cell :: {integer, integer}
  @type boat :: [cell]
  

  @doc """
    This function checks the validity of intended boat location in the player's game table
  """
  @spec is_position_valid?(boat, list, list) :: boolean
  
  def is_position_valid?(boat, [], _available_boats) do
    is_boat_on_grid?(boat)
  end

  def is_position_valid?(boat, [set_boat], _available_boats) do
    if is_boat_on_grid?(boat) do 
      Enum.filter(boat, &(!Enum.member?( illegal_cells( set_boat), &1) ) )
      |> length() == length(boat)
    else
      false
    end
  end

  def is_position_valid?(boat, list_boats = [ set_boat | tail ], available_boats) do
    if is_boat_available?(boat, list_boats, available_boats) do
      is_position_valid?(boat, [set_boat], available_boats) && is_position_valid?(boat, tail, available_boats)
    else
      false
    end
  end


  @doc """
   Function to check if player set all boats already
  """
  @spec all_boats_set?([boat], [integer]) :: boolean
  
  def all_boats_set?(boats, available_boats), do: boats_left_player(boats,available_boats) == []



  #SUPPORT FUNCTIONS 

  @doc """
  Function to check if cell is inside grid
  """
  @spec is_cell_valid?(cell) :: boolean

  def is_cell_valid?({x,y}), do: Enum.member?(0..9, x) && Enum.member?(0..9, y)

  @doc """
  Function to check if cells of a boat are inside grid
  """
  @spec is_boat_on_grid?(boat) :: boolean
  
  def is_boat_on_grid?(boat) do
    Enum.all?( boat, &( is_cell_valid?(&1) ) )
  end

  @doc """
  Function which returns list of adjacent cells for a given cell
  """
  @spec adjacent_cells(cell) :: [cell]

  def adjacent_cells({x,y}) do
    for i <- x - 1.. x + 1, j <- y - 1 .. y + 1 do
      if i == x or j == y, do: {i, j}
    end
    |> Enum.filter( &( !is_nil(&1) ) ) 
  end


  @doc """
    Function to consider the illegal cells to locate boats given a 
    """
  @spec illegal_cells(boat) :: [cell]
  
  def illegal_cells(set_boat) do
    illegal = []
    for {x,y} <- set_boat do
      illegal ++ adjacent_cells({x,y})
    end
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.filter(&( is_cell_valid?(&1) ) )
  end


  @doc """
  Function that returns the available boats for player to locate by their length
  """
  @spec boats_left_player([boat], list) :: boolean
  
  def boats_left_player(list_boats, available_boats) do
    available_boats -- Enum.map(list_boats, &(length(&1)))
  end


  @doc """
  Function to check if boat is available
  """
  @spec is_boat_available?(boat, [boat], list) :: boolean
  
  def is_boat_available?(boat, list_boats, available_boats) do
    boats_left_player(list_boats, available_boats)
    |> Enum.sort()
    |> Enum.member?( length( boat) )
  end


end
