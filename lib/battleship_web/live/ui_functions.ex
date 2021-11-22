defmodule BattleshipWeb.UIFunctions do
  def is_valid?(row, column, assigns) do
    boat_selected_length = assigns.you.available_boats |> Enum.at(assigns.you.boat_selected)
    #Ops.is_second_cell?(boat_selected_length, {row, column}, assigns.you.boats)
  end

  def whats_in_cell(row, column, assigns) do
    #Ops.get_cell(..
    if get_cell(row, column) == :water do
      :water
    else
      if surrounding_boat_cells(row, column) == 2 do
        :boat_body
      else
        if get_cell(row-1, column) == :water and get_cell(row+1, column) == :boat \
        or get_cell(row, column-1) == :water and get_cell(row, column+1) == :boat do
          :boat_tail
        else
          :boat_head
        end
    end


    end

  end

  defp surrounding_boat_cells(i, j) do
    check_surrounding(0, [{i-1, j-1}, {i-1, j}, {i-1, j+1}, {i, j-1}, {i, j+1}, {i+1, j-1}, {i+1, j}, {i+1, j+1}])
  end
  defp check_surrounding(acc, []), do: acc
  defp check_surrounding(acc, [{row, column} | t]) do
    if get_cell(row, column) == :boat do
      check_surrounding(acc+1, t)
    else
      check_surrounding(acc, t)
    end
  end

  defp get_cell(row, column) do
    case {row, column} do
      {0, 3} -> :boat
      {1, 3} -> :boat
      {2, 3} -> :boat
      {_, _} -> :water
    end
  end
end
