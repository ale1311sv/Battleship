defmodule Battleship.Opsetting do
  @doc """
    This function checks the validity of intended boat location in the player's game table
  """
  @spec is_position_valid?(boat, list, list) :: boolean
  
  def is_position_valid?(boat, [], available_boats) do
    is_boat_on_grid?(boat)
  end

  def is_position_valid?(boat, [set_boat], available_boats) do
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


  #SUPPORT FUNCTIONS 

  @doc """
  Function to check if cells of a boat are inside grid
  """
  @spec is_boat_on_grid?(boat) :: boolean
  def is_boat_on_grid?(boat) do
    for i <- 0 .. length(boat) - 1 do
      Enum.at( boat, i)
      |> Tuple.to_list()
      |> Enum.filter(&(&1 < @table_size))
      |> length() == 2
    end
    |> Enum.filter(&( &1 == false )) == []
  end

  @doc """
    Function to consider the illegal cells to locate boats given a 
    """
  @spec illegal_cells(boat) :: [cell]
  def illegal_cells(set_boat) do
    illegal = set_boat
    for {x,y} <- set_boat do
      illegal ++ [ { x + 1, y }, { x - 1, y }, {x, y + 1 }, {x, y - 1}, {x + 1, y + 1}, {x - 1, y - 1}, {x + 1, y - 1}, {x - 1, y + 1} ]
    end
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Function to check if boat is available
  """
  @spec is_boat_available?(boat, [boat], list) :: boolean
  def is_boat_available?(boat, list_boats, available_boats) do
    available_boats -- Enum.map(list_boats, &(length(&1)))
    |> Enum.sort()
    |> Enum.member?(length(boat))
  end
end
