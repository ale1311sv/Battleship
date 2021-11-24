defmodule Battleship.Operationsgame do
  @type cell :: {integer, integer}
  @type boat :: [cell]

  @doc """
  Function which checks if shot is valid according to the table size and shots already done
  """
  @spec is_shot_valid?(cell, [cell]) :: boolean

  def is_shot_valid?(shot, []), do: is_cell_valid?(shot)
  def is_shot_valid?(shot, [cell]), do: is_cell_valid?(shot) && shot != cell
  def is_shot_valid?(shot, [h | t]), do: is_shot_valid?(shot, [h]) && is_shot_valid?(shot, t)

  @doc """
  Function to analyse the impact of a received shot in someone's boats
  """
  @spec conseq_shots([cell], [boat]) :: atom

  def conseq_shots([shot], boats), do: if(did_it_miss?(shot, boats), do: :miss, else: :hit)

  def conseq_shots([shot | shots], boats) do
    if did_it_miss?(shot, boats) do
      :miss
    else
      boats_not_sunk =
        effects_shots_on_boats(shots, boats)
        |> Enum.filter(&(length(&1) != 0))

      last_shot_on_boats = effects_shots_on_boats([shot], boats_not_sunk)

      cond do
        List.flatten(last_shot_on_boats) == [] -> :end
        Enum.member?(last_shot_on_boats, []) -> :sunk
        true -> :hit
      end
    end
  end

  @doc """
    This function checks the validity of intended boat location in the player's game table
  """
  @spec is_position_valid?(boat, list, list) :: boolean

  def is_position_valid?(boat, [], available_boats) do
    is_boat_available?(boat, [], available_boats) && is_boat_on_grid?(boat)
  end

  def is_position_valid?(boat, [set_boat], available_boats) do
    if is_boat_on_grid?(boat) && is_boat_available?(boat, [set_boat], available_boats) do
      Enum.filter(boat, &(!Enum.member?(illegal_cells(set_boat), &1)))
      |> length() == length(boat)
    else
      false
    end
  end

  def is_position_valid?(boat, list_boats = [set_boat | tail], available_boats) do
    if is_boat_available?(boat, list_boats, available_boats) do
      is_position_valid?(boat, [set_boat], available_boats) &&
        is_position_valid?(boat, tail, available_boats)
    else
      false
    end
  end

  @doc """
   Function to check if player set all boats already
  """
  @spec all_boats_set?([boat], [integer]) :: boolean

  def all_boats_set?(boats, available_boats), do: boats_left_player(boats, available_boats) == []

  # SUPPORT FUNCTIONS

  @doc """
  Function to check if one shot missed
  """
  @spec did_it_miss?(cell, [boat]) :: boolean

  def did_it_miss?(shot, boats), do: not Enum.member?(List.flatten(boats), shot)

  @doc """
  Function to check if cell is inside grid
  """
  @spec is_cell_valid?(cell) :: boolean

  def is_cell_valid?({x, y}), do: Enum.member?(0..9, x) && Enum.member?(0..9, y)

  @doc """
  Function which returns the remaining cells of boats, the ones unharmed by shots
  """
  @spec effects_shots_on_boats([cell], [boat]) :: [[cell]]

  def effects_shots_on_boats(shots, [boat]), do: [boat -- shots]

  def effects_shots_on_boats(shots, [boat | boats]),
    do: effects_shots_on_boats(shots, [boat]) ++ effects_shots_on_boats(shots, boats)

  @doc """
  Function to check if cell is inside grid
  """
  @spec is_cell_valid?(cell) :: boolean

  def is_cell_valid?({x, y}), do: Enum.member?(0..9, x) && Enum.member?(0..9, y)

  @doc """
  Function to check if cells of a boat are inside grid
  """
  @spec is_boat_on_grid?(boat) :: boolean

  def is_boat_on_grid?(boat) do
    Enum.all?(boat, &is_cell_valid?(&1))
  end

  @doc """
  Function which returns list of adjacent cells for a given cell
  """
  @spec adjacent_cells(cell) :: [cell]

  def adjacent_cells({x, y}) do
    for i <- (x - 1)..(x + 1), j <- (y - 1)..(y + 1) do
      if i == x or j == y, do: {i, j}
    end
    |> Enum.filter(&(!is_nil(&1)))
  end

  @doc """
  Function to consider the illegal cells to locate boats given a 
  """
  @spec illegal_cells(boat) :: [cell]

  def illegal_cells(set_boat) do
    illegal = []

    for {x, y} <- set_boat do
      illegal ++ adjacent_cells({x, y})
    end
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.filter(&is_cell_valid?(&1))
  end

  @doc """
  Function that returns the available boats for player to locate by their length
  """
  @spec boats_left_player([boat], list) :: boolean

  def boats_left_player(list_boats, available_boats) do
    available_boats -- Enum.map(list_boats, &length(&1))
  end

  @doc """
  Function to check if boat is available
  """
  @spec is_boat_available?(boat, [boat], list) :: boolean

  def is_boat_available?(boat, list_boats, available_boats) do
    boats_left_player(list_boats, available_boats)
    |> Enum.sort()
    |> Enum.member?(length(boat))
  end
end
