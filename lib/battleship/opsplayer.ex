defmodule Battleship.Operationsplayer do
  @type cell :: {integer, integer}
  @type boat :: [cell]

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
  @spec are_cells_valid?(cell, cell) :: boolean

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
  @spec create_boat(cell, cell) :: boat

  def create_boat(cell1, celln) do
    case cells_alignment(cell1, celln) do
      :horizontal -> create_boat_horizontal(cell1, celln)
      :vertical -> create_boat_vertical(cell1, celln)
    end
  end

  # SUPPORT FUNCTIONS

  # Function to check if cell is inside grid
  @spec is_cell_valid?(cell) :: boolean

  defp is_cell_valid?({x, y}), do: Enum.member?(0..9, x) && Enum.member?(0..9, y)

  # Function which returns list of adjacent cells for a given cell
  @spec adjacent_cells(cell) :: [cell]

  defp adjacent_cells({x, y}) do
    for i <- (x - 1)..(x + 1), j <- (y - 1)..(y + 1) do
      if i == x or j == y, do: {i, j}
    end
    |> Enum.filter(&(!is_nil(&1)))
  end

  # Function to obtain illegal cells to locate a new boat given boats already located
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

  # Function to set the length of the future boat
  @spec distance_btw_cells({}, {}) :: integer

  defp distance_btw_cells(cell1, celln) do
    abs(elem(cell1, 0) - elem(celln, 0)) + abs(elem(cell1, 1) - elem(celln, 1))
  end

  # Function to check if LEGAL cells are vertical or horizontal aligned
  @spec cells_alignment({}, {}) :: atom

  defp cells_alignment(cell1, celln) do
    cond do
      elem(cell1, 0) == elem(celln, 0) -> :horizontal
      elem(cell1, 1) == elem(celln, 1) -> :vertical
    end
  end

  # Function which creats horizontal boats invoked by create_boat
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

  # Function which creats vertical boats invoked by create_boat
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
end
