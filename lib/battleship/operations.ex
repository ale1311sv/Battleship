defmodule Battleship.Operations do
  @type cell :: {integer, integer}
  @type boat :: [cell]

  # GAME

  # SETTING MODE

  @doc """
    This function checks the validity of intended boat location in the player's game table
  """
  @spec is_position_valid?(boat, list, list) :: boolean

  def is_position_valid?(boat, [], available_boats) do
    is_boat_available?(boat, [], available_boats) && is_boat_on_grid?(boat)
  end

  def is_position_valid?(boat, [set_boat], available_boats) do
    # if is_boat_on_grid?(boat) && is_boat_available?(boat, [set_boat], available_boats) do
    boat -- illegal_cells([set_boat]) == boat && is_boat_on_grid?(boat) &&
      is_boat_available?(boat, [set_boat], available_boats)

    # Enum.filter(boat, &(!Enum.member?(illegal_cells([set_boat]), &1)))
    # |> length() == length(boat)
    # else
    #  false
    # end
  end

  def is_position_valid?(boat, list_boats = [set_boat | tail], available_boats) do
    is_position_valid?(boat, [set_boat], available_boats) &&
      is_position_valid?(boat, tail, available_boats)
  end

  @doc """
  Function to check if boat position is valid ALTERNATIVE TO DISCUSS
  """
  @spec is_this_position_valid?(boat, [boat], [integer]) :: boolean

  def is_this_position_valid?(boat, boats, available_boats) do
    is_boat_on_grid?(boat) && is_boat_available?(boat, boats, available_boats) &&
      Enum.all?(boat, fn cell -> not Enum.member?(illegal_cells(boats), cell) end)
  end

  @doc """
   Function to check if player set all boats already
  """
  @spec all_boats_set?([boat], [integer]) :: boolean

  def all_boats_set?(boats, available_boats), do: boats_left(boats, available_boats) == []

  # PLAYERS MODE
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

  # PLAYER
  @doc """
  Function to obtain the possible second cells for a given selected cell and a length
  """
  @spec second_cells(integer, cell, [boat]) :: [cell]

  def second_cells(length, {x, y}, boats) do
    n = length - 1
    vertical = for i <- [x - n, x + n], do: {i, y}
    horizontal = for j <- [y - n, y + n], do: {x, j}

    ((vertical ++ horizontal) -- illegal_cells(boats))
    |> Enum.filter(&is_cell_valid?(&1))
  end

  @doc """
  Function to check if cell is inside grid
  """
  @spec is_cell_valid?({}) :: boolean

  def are_cells_valid?(cell1, celln), do: is_cell_valid?(cell1) && is_cell_valid?(celln)

  @doc """
  Function to check if requested cells can actually form a boat
  """
  @spec is_it_a_boat?(cell, cell) :: boolean

  def is_it_a_boat?(cell1, celln),
    do: elem(cell1, 0) == elem(celln, 0) or elem(cell1, 1) == elem(celln, 1)

  @doc """
  Function to check if selected cells to set a boat are right according to requested length
  """
  @spec are_selected_cells_intented_length?(cell, cell, integer) :: boolean

  def are_selected_cells_intented_length?(cell1, celln, length_boat_selected),
    do: distance_btw_cells(cell1, celln) + 1 == length_boat_selected

  @doc """
  Function to create a boat from cells WORKS ONLY FOR well defined wannabe boats
  """
  @spec create_boat({}, {}) :: [{}]

  def create_boat(cell1, celln) do
    case cells_alignment(cell1, celln) do
      :horizontal -> create_boat_horizontal(cell1, celln)
      :vertical -> create_boat_vertical(cell1, celln)
    end
  end

  # UI

  @doc """
  Function to check whether cell is part of a boat or just water
  """
  @spec what_is_cell(cell, boat) :: atom

  def what_is_cell(cell, boats) do
    if Enum.member?(List.flatten(boats), cell) do
      :boat
    else
      :water
    end
  end

  @doc """
  Function to check whether cell is hit or not
  """
  @spec how_is_cell(cell, [cell]) :: atom

  def how_is_cell(cell, shots) do
    if Enum.member?(shots, cell) do
      :hit
    else
      :unharmed
    end
  end

  @doc """
  Function to check if cell is a possible second cell for boat selection given selected cell
  """
  @spec is_second_cell?(integer, cell, cell, [boat]) :: boolean

  def is_second_cell?(length, selected_cell, cell, boats),
    do: Enum.member?(second_cells(length, selected_cell, boats), cell)

  # SUPPORT FUNCTIONS

  @doc """
  Function to check if cell is inside grid
  """
  @spec is_cell_valid?(cell) :: boolean

  defp is_cell_valid?({x, y}), do: Enum.member?(0..9, x) && Enum.member?(0..9, y)

  @doc """
  Function which returns list of adjacent cells for a given cell
  """
  @spec adjacent_cells(cell) :: [cell]

  defp adjacent_cells({x, y}) do
    for i <- (x - 1)..(x + 1), j <- (y - 1)..(y + 1) do
      if i == x or j == y, do: {i, j}
    end
    |> Enum.filter(&(!is_nil(&1)))
  end

  @doc """
  Function to obtain illegal cells to locate a new boat given boats already located
  """
  @spec illegal_cells([boat]) :: [cell]

  defp illegal_cells([set_boat]) do
    illegal = []

    for {x, y} <- set_boat do
      illegal ++ adjacent_cells({x, y})
    end
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.filter(&is_cell_valid?(&1))
  end

  defp illegal_cells([h | t]), do: illegal_cells([h]) ++ illegal_cells(t)

  @doc """
  Function to check if cells of a boat are inside grid
  """
  @spec is_boat_on_grid?(boat) :: boolean

  defp is_boat_on_grid?(boat) do
    Enum.all?(boat, &is_cell_valid?(&1))
  end

  @doc """
  Function that returns the available boats for player to locate by their length
  """
  @spec boats_left([boat], list) :: boolean

  defp boats_left(list_boats, available_boats) do
    available_boats -- Enum.map(list_boats, &length(&1))
  end

  @doc """
  Function to check if boat is available
  """
  @spec is_boat_available?(boat, [boat], list) :: boolean

  defp is_boat_available?(boat, list_boats, available_boats) do
    boats_left(list_boats, available_boats)
    |> Enum.sort()
    |> Enum.member?(length(boat))
  end

  @doc """
  Function to set the length of the future boat
  """
  @spec distance_btw_cells({}, {}) :: integer

  defp distance_btw_cells(cell1, celln) do
    abs(elem(cell1, 0) - elem(celln, 0)) + abs(elem(cell1, 1) - elem(celln, 1))
  end

  @doc """
  Function to check if LEGAL cells are vertical or horizontal aligned
  """
  @spec cells_alignment({}, {}) :: atom

  defp cells_alignment(cell1, celln) do
    cond do
      elem(cell1, 0) == elem(celln, 0) -> :horizontal
      elem(cell1, 1) == elem(celln, 1) -> :vertical
    end
  end

  @doc """
  Function which creats horizontal boats invoked by create_boat
  """
  @spec create_boat_horizontal({}, {}) :: [{}]

  defp create_boat_horizontal(cell1, celln) do
    x = elem(cell1, 0)
    n = distance_btw_cells(cell1, celln)

    y =
      [elem(cell1, 1), elem(celln, 1)]
      |> Enum.sort()
      |> Enum.at(0)

    for j <- y..(y + n), do: {x, j}
  end

  @doc """
  Function which creats vertical boats invoked by create_boat
  """
  @spec create_boat_vertical({}, {}) :: [{}]

  defp create_boat_vertical(cell1, celln) do
    y = elem(cell1, 1)
    n = distance_btw_cells(cell1, celln)

    x =
      [elem(cell1, 0), elem(celln, 0)]
      |> Enum.sort()
      |> Enum.at(0)

    for i <- x..(x + y + n), do: {i, y}
  end

  @doc """
  Function to check if one shot missed
  """
  @spec did_it_miss?(cell, [boat]) :: boolean

  defp did_it_miss?(shot, boats), do: not Enum.member?(List.flatten(boats), shot)

  @doc """
  Function which returns the remaining cells of boats, the ones unharmed by shots
  """
  @spec effects_shots_on_boats([cell], [boat]) :: [[cell]]

  defp effects_shots_on_boats(shots, [boat]), do: [boat -- shots]

  defp effects_shots_on_boats(shots, [boat | boats]),
    do: effects_shots_on_boats(shots, [boat]) ++ effects_shots_on_boats(shots, boats)
end
