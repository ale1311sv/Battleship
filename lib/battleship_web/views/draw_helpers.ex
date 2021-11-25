defmodule BattleshipWeb.DrawHelpers do
  @moduledoc """
  This is the module where all the necessary functions for processing data and drawing
  elements in the canvas are located. The majority of them return strings that will be added to
  element CSS classes.
  """

  alias Battleship.Game
  alias Battleship.Operations

  @doc """
  Says if a cell ({'row', 'column'}) could be clicked by the user or not, depending on the
  state of the game (as it's set in 'assigns').

  Returns "enabled" or "disabled"
  """
  @spec clickable(Game.cell(), [Game.boat()], non_neg_integer(), Game.cell()) :: String.t()
  def clickable(cell, boats, boat_selected, first_cell_selected) do
    cond do
      is_nil(boat_selected) ->
        ""

      is_nil(first_cell_selected) ->
        if Operations.is_first_cell?(boat_selected, cell, boats),
          do: "visibly enabled",
          else: "disabled"

      true ->
        if Operations.is_second_cell?(boat_selected, first_cell_selected, cell, boats),
          do: "visibly enabled",
          else: "disabled"
    end
  end

  def shootable(cell, shots) do
    if Operations.is_shot_legal?(cell, shots), do: "enabled", else: "disabled"
  end

  @doc """
  Specifies which actual image will be drawn in the given 'cell', knowing which 'boats' are
  already located in the board.

  Returns "CONTENT ALIGNMENT", for example "boat_body horizontal"
  """
  @spec image(Game.cell(), [Game.boats()]) :: String.t()
  def image(cell, boats), do: "#{content(cell, boats)} #{alignment(cell, boats)}"

  @doc """
  Specifies which actual image will be drawn in the given 'cell', knowing which 'boats' are
  already located in the board and the 'shots' executed by the enemy.

  Returns "CONTENT ALIGNMENT EFFECT", for example "boat_body horizontal hit"
  """
  @spec image(Game.cell(), [Game.boats()], [Game.cell()], atom()) :: String.t()
  def image(cell, boats, shots, :you) do
    "#{content(cell, boats)} #{alignment(cell, boats)} #{effects(cell, boats, shots)}"
  end

  def image(cell, boats, shots, :enemy) do
    if Operations.how_is_cell(cell, shots) == :unharmed do
      "secret"
    else
      "#{content(cell, boats)} #{alignment(cell, boats)} #{effects(cell, boats, shots)}"
    end
  end

  # Calculate the drawable content of the cell. If it is a boat, which specific part of the boat
  @spec content(Game.cell(), [Game.boats()]) :: String.t()
  defp content({row, column}, boats) do
    main_cell = Operations.what_is_cell({row, column}, boats)
    left_cell = Operations.what_is_cell({row, column - 1}, boats)
    right_cell = Operations.what_is_cell({row, column + 1}, boats)
    top_cell = Operations.what_is_cell({row - 1, column}, boats)
    bottom_cell = Operations.what_is_cell({row + 1, column}, boats)

    cond do
      main_cell == :water ->
        "water"

      # Is it surrounded by 2 boat cells? It must be the BODY
      Enum.count([left_cell, right_cell, top_cell, bottom_cell], &(&1 == :boat)) == 2 ->
        "boat_body"

      # We fixed that the top part in a vertical boat and the left part
      # in an horizontal boat will always be the TAIL
      (top_cell == :water and bottom_cell == :boat) or
          (left_cell == :water and right_cell == :boat) ->
        "boat_tail"

      true ->
        "boat_head"
    end
  end

  # Check the alignment of the boat which the cell (row 'i', column 'j') belongs to.
  @spec alignment(Game.cell(), [Game.boat()]) :: String.t()
  defp alignment({row, column}, boats) do
    top_cell = Operations.what_is_cell({row - 1, column}, boats)
    bottom_cell = Operations.what_is_cell({row + 1, column}, boats)

    if Enum.count([top_cell, bottom_cell], &(&1 == :boat)) != 0,
      do: "vertical",
      else: "horizontal"
  end

  # Calculate the effect to overdraw into the content of the cell. A hit or a boat sunk
  defp effects(cell, boats, shots) do
    content = Operations.what_is_cell(cell, boats)
    effect = Operations.how_is_cell(cell, shots)
    sunk_cells = List.flatten(Operations.sunk_boats(shots, boats))

    cond do
      effect == :hit and content == :water ->
        "miss"

      effect == :hit and content == :boat ->
        if Enum.member?(sunk_cells, cell), do: "sunk", else: "hit"

      true ->
        ""
    end

    # end
  end
end
