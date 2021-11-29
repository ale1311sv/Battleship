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
  @spec clickable_class(Game.cell(), map()) :: String.t()
  def clickable_class(cell, %{mode: :setting} = params) do
    cond do
      is_nil(params.boat_selected) ->
        ""

      is_nil(params.cell_selected) ->
        if Operations.is_first_cell?(params.boat_selected, cell, params.boats),
          do: "visibly enabled",
          else: "disabled"

      true ->
        if Operations.is_second_cell?(
             params.boat_selected,
             params.cell_selected,
             cell,
             params.boats
           ),
           do: "visibly enabled",
           else: "disabled"
    end
  end

  def clickable_class(_cell, %{mode: :playing, player: :you}), do: ""

  # def clickable_class(_cell, %{mode: :playing, player: :enemy, turn: :enemy}), do: "disabled"

  def clickable_class(cell, %{mode: :playing, player: :enemy} = params) do
    if Operations.is_shot_legal?(cell, params.shots), do: "enabled", else: "disabled"
  end

  @doc """
  """
  def content_class(cell, :full, boats, []),
    do: "#{element(cell, boats)} #{alignment(cell, boats)}"

  def content_class(cell, :full, boats, shots),
    do: "#{element(cell, boats)} #{alignment(cell, boats)} #{effect(cell, boats, shots)}"

  def content_class(cell, :restricted, boats, shots) do
    if Operations.how_is_cell(cell, shots) == :unharmed do
      "secret"
    else
      "#{element(cell, boats)} #{alignment(cell, boats)} #{effect(cell, boats, shots)} restricted"
    end
  end

  # Calculate the drawable content of the cell. If it is a boat, which specific part of the boat
  @spec element(Game.cell(), [Game.boats()]) :: String.t()
  defp element({row, column}, boats) do
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
  defp effect(cell, boats, shots) do
    cell_element = Operations.what_is_cell(cell, boats)
    cell_effect = Operations.how_is_cell(cell, shots)
    sunk_cells = List.flatten(Operations.sunk_boats(shots, boats))

    cond do
      cell_effect == :hit and cell_element == :water ->
        "miss"

      cell_effect == :hit and cell_element == :boat ->
        if Enum.member?(sunk_cells, cell), do: "sunk", else: "hit"

      true ->
        ""
    end

    # end
  end
end
