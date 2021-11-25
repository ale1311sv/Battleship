defmodule Battleship.Operations do
  alias Battleship.Game
  # GAME

  # SETTING MODE

  @spec is_boat_available?(Game.boat(), [Game.boat()], [pos_integer()]) :: boolean
  def is_boat_available?(boat, list_boats, available_boats) do
    list_boats
    |> lengths_left(available_boats)
    |> Enum.member?(length(boat))
  end

  @doc """
  Function to check if boat position is valid ALTERNATIVE TO DISCUSS
  """
  @spec is_boat_location_valid?(Game.boat(), [Game.boat()]) :: boolean
  def is_boat_location_valid?(boat, boats) do
    is_boat_on_grid?(boat) && Enum.all?(boat, &is_cell_legal?(&1, boats))
  end

  @doc """
   Function to check if player set all boats already
  """
  @spec all_boats_set?([Game.boat()], [pos_integer]) :: boolean
  def all_boats_set?(boats, available_boats), do: lengths_left(boats, available_boats) == []

  # PLAYERS MODE
  @doc """
  Function which checks if shot is valid according to the table size and shots already done
  """
  @spec is_shot_valid?(Game.cell(), [Game.cell()]) :: boolean
  def is_shot_valid?(shot, []), do: is_cell_valid?(shot)
  def is_shot_valid?(shot, [cell]), do: is_cell_valid?(shot) && shot != cell
  def is_shot_valid?(shot, [h | t]), do: is_shot_valid?(shot, [h]) && is_shot_valid?(shot, t)

  # Function to check if one shot missed
  @spec hit?(Game.cell(), [Game.boat()]) :: boolean
  def hit?(shot, boats), do: Enum.member?(List.flatten(boats), shot)

  @spec is_game_end?([Game.cell()], [Game.boat()]) :: boolean
  def is_game_end?(shots, boats) do
    boats_flatten = List.flatten(boats)
    MapSet.subset?(MapSet.new(boats_flatten), MapSet.new(shots))
  end

  @doc """
  Function to analyse the impact of a received shot in someone's boats
  """
  @spec conseq_shots([Game.cell()], [Game.boat()]) :: atom
  def conseq_shots([shot], boats), do: if(not hit?(shot, boats), do: :miss, else: :hit)

  def conseq_shots([shot | shots], boats) do
    if not hit?(shot, boats) do
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
  @spec second_cells(integer, Game.cell(), [Game.boat()]) :: [Game.cell()]
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
  @spec are_cells_valid?(Game.cell(), Game.cell()) :: boolean
  def are_cells_valid?(cell1, celln), do: is_cell_valid?(cell1) && is_cell_valid?(celln)

  @doc """
  Function to check if requested cells can actually form a boat
  """
  @spec is_it_a_boat?(Game.cell(), Game.cell()) :: boolean
  def is_it_a_boat?(cell1, celln),
    do: elem(cell1, 0) == elem(celln, 0) or elem(cell1, 1) == elem(celln, 1)

  @doc """
  Function to check if selected cells to set a boat are right according to requested length
  """
  @spec are_selected_cells_intented_length?(Game.cell(), Game.cell(), non_neg_integer()) ::
          boolean
  def are_selected_cells_intented_length?(cell1, celln, length_boat_selected),
    do: distance_btw_cells(cell1, celln) + 1 == length_boat_selected

  @doc """
  Function to create a boat from cells WORKS ONLY FOR well defined wannabe boats
  """
  @spec create_boat(Game.cell(), Game.cell()) :: Game.boat()
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
  @spec what_is_cell(Game.cell(), Game.boat()) :: atom
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
  @spec how_is_cell(Game.cell(), [Game.cell()]) :: atom
  def how_is_cell(cell, shots) do
    if Enum.member?(shots, cell) do
      :hit
    else
      :unharmed
    end
  end

  @spec is_first_cell?(pos_integer, Game.cell(), [Game.boat()]) :: boolean
  def is_first_cell?(length_boat_selected, cell, boats) do
    not Enum.member?(illegal_cells(boats), cell) &&
      will_any_future_boat_fit?(length_boat_selected, cell, boats)
  end

  @doc """
  Function to check if cell is a possible second cell for boat selection given selected cell
  """
  @spec is_second_cell?(pos_integer, Game.cell(), Game.cell(), [Game.boat()]) :: boolean
  def is_second_cell?(length, selected_cell, cell, boats),
    do: Enum.member?(second_cells(length, selected_cell, boats), cell)

  # SUPPORT FUNCTIONS

  # Function to check if cell is inside grid
  @spec is_cell_valid?(Game.cell()) :: boolean
  def is_cell_valid?({x, y}), do: Enum.member?(0..9, x) && Enum.member?(0..9, y)

  @spec is_cell_legal?(Game.cell(), [Game.boat()]) :: boolean
  defp is_cell_legal?(cell, boats) do
    not Enum.member?(illegal_cells(boats), cell)
  end

  # Function which returns list of adjacent cells for a given cell
  @spec adjacent_cells(Game.cell()) :: [Game.cell()]
  defp adjacent_cells({x, y}) do
    for i <- (x - 1)..(x + 1), j <- (y - 1)..(y + 1) do
      if i == x or j == y, do: {i, j}
    end
    |> Enum.reject(&is_nil(&1))
    |> Enum.filter(&is_cell_valid?(&1))
  end

  # Function to obtain illegal cells to locate a new boat given boats already located
  @spec illegal_cells([Game.boat()]) :: [Game.cell()]
  defp illegal_cells(boats) do
    for {x, y} <- List.flatten(boats) do
      adjacent_cells({x, y})
    end
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
  end

  @spec will_any_future_boat_fit?(pos_integer, Game.cell(), [Game.boat()]) :: boolean
  defp will_any_future_boat_fit?(length, cell, boats) do
    will_any_future_boat_vertical_fit?(length, cell, boats) ||
      will_any_future_boat_horizontal_fit?(length, cell, boats)
  end

  @spec will_any_future_boat_vertical_fit?(pos_integer, Game.cell(), [Game.boat()]) :: boolean
  defp will_any_future_boat_vertical_fit?(length, cell = {x, y}, boats),
    do:
      is_second_cell?(length, cell, {x + length - 1, y}, boats) ||
        is_second_cell?(length, cell, {x - length + 1, y}, boats)

  @spec will_any_future_boat_horizontal_fit?(pos_integer, Game.cell(), [Game.boat()]) :: boolean
  defp will_any_future_boat_horizontal_fit?(length, cell = {x, y}, boats),
    do:
      is_second_cell?(length, cell, {x, y + length - 1}, boats) ||
        is_second_cell?(length, cell, {x, y - length + 1}, boats)

  # Function to check if cells of a boat are inside grid
  @spec is_boat_on_grid?(Game.boat()) :: boolean
  defp is_boat_on_grid?(boat) do
    Enum.all?(boat, &is_cell_valid?(&1))
  end

  # Function that returns the available boats for player to locate by their length
  @spec lengths_left([Game.boat()], [pos_integer()]) :: [pos_integer()]
  defp lengths_left(list_boats, available_boats) do
    available_boats -- Enum.map(list_boats, &length(&1))
  end

  # Function to set the length of the future boat
  @spec distance_btw_cells(Game.cell(), Game.cell()) :: non_neg_integer
  defp distance_btw_cells(cell1, celln) do
    abs(elem(cell1, 0) - elem(celln, 0)) + abs(elem(cell1, 1) - elem(celln, 1))
  end

  # Function to check if LEGAL cells are vertical or horizontal aligned
  @spec cells_alignment(Game.cell(), Game.cell()) :: atom
  defp cells_alignment(cell1, celln) do
    cond do
      elem(cell1, 0) == elem(celln, 0) -> :horizontal
      elem(cell1, 1) == elem(celln, 1) -> :vertical
    end
  end

  # Function which creats horizontal boats invoked by create_boat
  @spec create_boat_horizontal(Game.cell(), Game.cell()) :: Game.boat()
  defp create_boat_horizontal(cell1, celln) do
    x = elem(cell1, 0)
    n = distance_btw_cells(cell1, celln)

    y =
      [elem(cell1, 1), elem(celln, 1)]
      |> Enum.sort()
      |> Enum.at(0)

    for j <- y..(y + n), do: {x, j}
  end

  # Function which creats vertical boats invoked by create_boat
  @spec create_boat_vertical(Game.cell(), Game.cell()) :: Game.boat()
  def create_boat_vertical(cell1, celln) do
    y = elem(cell1, 1)
    n = distance_btw_cells(cell1, celln)

    x =
      [elem(cell1, 0), elem(celln, 0)]
      |> Enum.sort()
      |> Enum.at(0)

    for i <- x..(x + n), do: {i, y}
  end

  # Function which returns the remaining cells of boats, the ones unharmed by shots
  @spec effects_shots_on_boats([Game.cell()], [Game.boat()]) :: [[Game.cell()]]
  defp effects_shots_on_boats(shots, [boat]), do: [boat -- shots]

  defp effects_shots_on_boats(shots, [boat | boats]),
    do: effects_shots_on_boats(shots, [boat]) ++ effects_shots_on_boats(shots, boats)
end
