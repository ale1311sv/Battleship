defmodule BattleshipWeb.DrawHelpers do
  @moduledoc """
  This is the module where all the necessary functions for processing data and drawing
  elements in the canvas are located. The majority of them return strings that will be added to
  element CSS classes.
  """

  @type cell :: {non_neg_integer(), non_neg_integer()}
  @type boat :: [cell]
  @type socket :: %{
          you: %{
            available_boats: [non_neg_integer()],
            boats: [boat],
            shots: [cell],
            first_cell_selected: cell,
            boat_selected: non_neg_integer()
          },
          enemy: %{
            boats: [boat],
            shots: [cell]
          },
          mode: atom(),
          submode: atom()
        }

  @doc """
  Says if a cell ({'row', 'column'}) could be clicked by the user or not, depending on the
  state of the game (as it's set in 'assigns').

  Returns "enabled" or "disabled"
  """
  @spec clickable(cell, [boat], list(non_neg_integer()), non_neg_integer()) :: atom()
  def clickable({_row, _column}, _boats, available_boats, boat_selected) do
    #boat_selected_length = available_boats |> Enum.at(boat_selected)
    # Ops.is_second_cell?(boat_selected_length, {row, column}, assigns.you.boats)
  end

  @doc """
  Says which physical kind of element of the game must be drawn inside that cell ({'row',
  'column'}) ) depending on what's inside of it according with the general state of the
  game (:water or :boat). About boats, it considers the alignment of the full boat which
  that cell belongs to, as if it is the tail, body or head of the boat.

  Returns '"BOAT_PART ALIGNMENT"'', being:
  - BOAT_PART: boat_head, boat_body or boat_tail
  """
  @spec content(cell, [boat], [cell]) :: String.t()
  def content({row, column}, _boats, _shots) do
    # cell = Ops.what_is_cell(row, column, row)
    cell = what_is_cell(row, column)

    if cell == :water do
      "water"
    else
      if surrounding_boat_cells(row, column) == 2 do
        "boat_body #{alignment(row, column)}"
      else
        if (what_is_cell(row - 1, column) == :water and what_is_cell(row + 1, column) == :boat) or
             (what_is_cell(row, column - 1) == :water and what_is_cell(row, column + 1) == :boat) do
          "boat_tail #{alignment(row, column)}"
        else
          "boat_head #{alignment(row, column)}"
        end
      end
    end
  end

  # Check the alignment of the boat which the cell (row 'i', column 'j') belongs to.
  # Returns ':vertical' or ':horizontal'
  @spec alignment(non_neg_integer(), non_neg_integer()) :: atom()
  defp alignment(i, j) do
    if count_boat_in_cells(0, [{i - 1, j}, {i + 1, j}]) != 0, do: :vertical, else: :horizontal
  end

  # Returns the number of surrounding boat cells of a specific cell (row 'i', column 'j')
  defp surrounding_boat_cells(i, j) do
    count_boat_in_cells(0, [{i - 1, j}, {i + 1, j}, {i, j - 1}, {i, j + 1}])
  end

  # Returns the number of boat in the list of cells given
  defp count_boat_in_cells(acc, []), do: acc
  defp count_boat_in_cells(acc, [{row, column} | t]) do
    if what_is_cell(row, column) == :boat do
      count_boat_in_cells(acc + 1, t)
    else
      count_boat_in_cells(acc, t)
    end
  end

  # Trial function that imitates the Ops API
  defp what_is_cell(row, column) do
    case {row, column} do
      {9, 5} -> :boat
      {9, 6} -> :boat
      {2, 5} -> :boat
      {3, 5} -> :boat
      {4, 5} -> :boat
      {5, 5} -> :boat
      {1, 1} -> :boat
      {1, 2} -> :boat
      {1, 3} -> :boat
      {3, 1} -> :boat
      {4, 1} -> :boat
      {5, 1} -> :boat
      {_, _} -> :water
    end
  end
end
