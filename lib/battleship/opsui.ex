defmodule Battleship.OperationsUI do
  @type cell :: {integer, integer}
  @type boat :: [cell]

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

  # Function to obtain the possible second cells for a given selected cell and a length
  @spec second_cells(integer, cell, [boat]) :: [cell]

  defp second_cells(length, {x, y}, boats) do
    n = length - 1
    vertical = for i <- [x - n, x + n], do: {i, y}
    horizontal = for j <- [y - n, y + n], do: {x, j}

    ((vertical ++ horizontal) -- illegal_cells(boats))
    |> Enum.filter(&is_cell_valid?(&1))
  end
end
