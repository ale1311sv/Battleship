defmodule Battleship.Operations do
  alias Battleship.Game
  @moduledoc """

  In this module a cell is a duple (tuple of length 2) of integers which is used to represent a matricial space of Battleship grid (set to size 10)
  Then, a boat is a list of sorted cells determined by its length and its coordinates (represented by cells). 
  There's a shot, which is a cell representing the attempt to hit a boat, but I can land in water (cells of grid which are not part of boats). This will be called a miss.
  If all cell of a boat are hit, then it's sunk. If all boats are sunk, the game ends.

  valid indicates that element is INSIDE grid
  legal means that element FOLLOWS rules (e.g. we cannot locate boats adjacently or shoot twice the same spot)
  available denotes that element is PART of the RESOURCES that aren't yet USED
  """

# GAME

  # SETTING MODE
  @doc """
  Function to check if I can set one boat in grid given already located boats and available_boats list of lengths (of boats) available (determined by rules of the game)
  is_boat_available?(boat, boats, available_boats)
  """
  @spec is_boat_available?(Game.boat(), [Game.boat()], [pos_integer()]) :: boolean
  def is_boat_available?(boat, boats, available_boats) do
    boats
    |> lengths_left(available_boats)
    |> Enum.member?(length(boat))
  end

  @doc """
  Function to check if request of locating boat can be accomplished given already located boats
  is_boat_location_valid?(boat, boats)
  """
  @spec is_boat_location_legal?(Game.boat(), [Game.boat()]) :: boolean
  def is_boat_location_legal?(boat, boats) do
    is_boat_location_valid?(boat) && Enum.all?(boat, &is_cell_legal?(&1, boats))
  end

  @doc """
  Function to check if player set all boats already given available_boats list of lengths (of boats) available (determined by rules of the game)
  all_boats_set?(boats_set, available_boats)
  """
  @spec all_boats_set?([Game.boat()], [pos_integer]) :: boolean
  def all_boats_set?(boats, available_boats), do: lengths_left(boats, available_boats) == []

  # PLAYERS MODE
  
  @spec is_shot_legal?(Game.cell(), [Game.cell()]) :: boolean
  def is_shot_legal?(shot, []), do: is_cell_valid?(shot)
  def is_shot_legal?(shot, [cell]), do: is_cell_valid?(shot) && shot != cell
  def is_shot_legal?(shot, [h | t]), do: is_shot_legal?(shot, [h]) && is_shot_legal?(shot, t)
  
  @spec hit?(Game.cell(), [Game.boat()]) :: boolean
  def hit?(shot, boats), do: Enum.member?(List.flatten(boats), shot)

  @spec is_game_end?([Game.cell], [Game.boat]) :: boolean
  def is_game_end?(shots, boats) do
    boats_flatten = List.flatten(boats)
    MapSet.subset?(MapSet.new(boats_flatten), MapSet.new(shots))
  end


# PLAYER
  @spec second_cells(pos_integer, Game.cell(), [Game.boat()]) :: [Game.cell()]
  def second_cells(length, cell, boats) do
    likely_second_cells(length, cell)
    |> Enum.filter(&will_future_boat_fit?(cell, &1, boats))
  end

  @spec are_cells_valid?(Game.cell, Game.cell) :: boolean
  def are_cells_valid?(cell1, celln), do: is_cell_valid?(cell1) && is_cell_valid?(celln)

  @spec is_it_a_boat?(Game.cell(), Game.cell()) :: boolean
  def is_it_a_boat?(cell1, celln),
    do: elem(cell1, 0) == elem(celln, 0) or elem(cell1, 1) == elem(celln, 1)

  @spec are_sel_cells_intented_length?(non_neg_integer, Game.cell(), Game.cell()) :: boolean
  def are_sel_cells_intented_length?(length_boat_selected, cell1, celln),
    do: distance_btw_cells(cell1, celln) + 1 == length_boat_selected

  @doc """
  Function to create a boat from cells WORKS ONLY FOR well defined wannabe boats
  """
  @spec create_boat(Game.cell, Game.cell) :: Game.boat
  def create_boat(cell1, celln) do
    case cells_alignment(cell1, celln) do
      :horizontal -> create_boat_horizontal(cell1, celln)
      :vertical -> create_boat_vertical(cell1, celln)
    end
  end

  # UI

  @doc """
  Function to check whether cell is part of a boat or just water
  what_is_cell(cell, boats) returns :boat if cell is part of a boat, otherwise returns :water
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
  how_is_cell(cell, shots) returns :hit if there's a shot in cell, otherwise returns :unharmed
  """
  @spec how_is_cell(Game.cell(), [Game.cell()]) :: atom
  def how_is_cell(cell, shots) do
    if Enum.member?(shots, cell) do
      :hit
    else
      :unharmed
    end
  end


  @doc """
  Function to check if I should select one cell to locate a boat whose length is length_boat_selected
  is_first_cell?(length_boat_selected, cell, boats) returns true if exists any legal boat from cell of mentioned length
  """
  @spec is_first_cell?(pos_integer, Game.cell, [Game.boat]) :: boolean
  def is_first_cell?(length_boat_selected, cell, boats) do 
    not Enum.member?(illegal_cells(boats), cell) && will_any_future_boat_fit?(length_boat_selected, cell, boats)
  end

  @doc """
  Function to check if cell is a possible second cell for boat selection given selected cell
  is_second_cell?(length_boat_selected, selected_cell, cell) returns true if I could create legal boat from selected_cell to cell
  """
  @spec is_second_cell?(pos_integer, Game.cell(), Game.cell(), [Game.boat()]) :: boolean
  def is_second_cell?(length, selected_cell, cell, boats), do: Enum.member?(second_cells(length, selected_cell, boats), cell)
  
  @doc """
  Function to understand the result of the last shot which could be 
  last_shot_result(shots, boats) -> :miss, :hit, :sunk or :end
  """
  @spec last_shot_result([Game.cell], [Game.boat]) :: atom
  def last_shot_result(shots, boats), do: conseq_shots(Enum.reverse(shots), boats)

  @spec sunk_boats([Game.cell], [Game.boat]) :: [Game.boat]
  def sunk_boats(shots, boats) do
    for boat <- boats do
      if MapSet.subset?(MapSet.new(boat), MapSet.new(shots)), do: boat
    end
    |> Enum.reject(&is_nil(&1))
  end

  # SUPPORT FUNCTIONS

  @spec is_cell_valid?(Game.cell()) :: boolean
  defp is_cell_valid?({x, y}), do: Enum.member?(0..9, x) && Enum.member?(0..9, y)
  
  @spec is_cell_legal?(Game.cell(), [Game.boat()]) :: boolean
  defp is_cell_legal?(cell, boats) do
    not Enum.member?(illegal_cells(boats), cell)
  end

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

  @spec will_future_boat_fit?(Game.cell, Game.cell, [Game.boat]) :: boolean
  defp will_future_boat_fit?(cell1, celln, boats) do
    create_boat(cell1, celln)
    |> is_boat_location_legal?(boats)
  end

  @spec likely_second_cells(pos_integer, Game.cell) :: boolean
  defp likely_second_cells(length, {x,y}) do 
    n = length - 1
    vertical = for i <- [x - n, x + n], do: {i, y}
    horizontal = for j <- [y - n, y + n], do: {x, j}
    vertical ++ horizontal
      |> Enum.filter(&is_cell_valid?(&1))
  end
  
  @spec will_any_future_boat_fit?(pos_integer, Game.cell, [Game.boat]) :: boolean
  defp will_any_future_boat_fit?(length_boat_selected, cell, boats) do
    Enum.any?( likely_second_cells(length_boat_selected, cell), &will_future_boat_fit?(cell, &1, boats))
  end

  @spec is_boat_location_valid?(Game.boat()) :: boolean
  defp is_boat_location_valid?(boat) do
    Enum.all?(boat, &is_cell_valid?(&1))
  end

  # Function that returns the available boats for player to locate by their length
  @spec lengths_left([Game.boat()], [pos_integer()]) :: [pos_integer()]
  defp lengths_left(list_boats, available_boats) do
    available_boats -- Enum.map(list_boats, &length(&1))
  end

  @spec distance_btw_cells(Game.cell, Game.cell):: non_neg_integer
  defp distance_btw_cells(cell1, celln) do
    abs(elem(cell1, 0) - elem(celln, 0)) + abs(elem(cell1, 1) - elem(celln, 1))
  end

  # Function to check if LEGAL cells are vertical or horizontal aligned
  @spec cells_alignment(Game.cell, Game.cell):: atom
  defp cells_alignment(cell1, celln) do
    cond do
      elem(cell1, 0) == elem(celln, 0) -> :horizontal
      elem(cell1, 1) == elem(celln, 1) -> :vertical
    end
  end

  @spec create_boat_horizontal(Game.cell, Game.cell) :: Game.boat
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
  @spec create_boat_vertical(Game.cell, Game.cell ):: Game.boat
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
    
  @spec conseq_shots([Game.cell()], [Game.boat()]) :: atom
  defp conseq_shots([], _), do: :miss
  defp conseq_shots([shot], boats), do: if not hit?(shot, boats), do: :miss, else: :hit
  defp conseq_shots([shot | shots], boats) do
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
end
