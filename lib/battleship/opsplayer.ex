defmodule Battleship.Operationsplayer do
  @type cell :: {integer, integer}
  @type boat :: [cell]

  @doc """
  Function to check if cell is inside grid
  """
  @spec is_cell_valid?({}) :: boolean

  def is_cell_valid?({x, y}), do: Enum.member?(0..9, x) && Enum.member?(0..9, y)

  @doc """
  Function to check if requested cells can actually form a boat
  """
  @spec is_it_a_boat?(cell, cell) :: boolean

  def is_it_a_boat?(cell1, celln),
    do: elem(cell1, 0) == elem(celln, 0) or elem(cell1, 1) == elem(celln, 1)

  @doc """
  Function to check if selected cells to set a boat are right
  """
  @spec was_boat_selection_right?({}, {}, integer) :: boolean

  def was_boat_selection_right?(cell1, celln, length_boat_selected),
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

  # SUPPORT FUNCTIONS

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
end
