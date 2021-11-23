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
end
