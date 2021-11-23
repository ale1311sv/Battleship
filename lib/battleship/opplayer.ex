defmodule Battleship.Opplayer do
  
  @type cell :: {integer, integer}
  @type boat :: [cell]

  @doc """
  Function which checks if shot is valid according to the table size and shots already done
  """
  @spec is_shot_valid?(cell, [cell]) :: boolean
  
  def is_shot_valid?(shot, []), do: is_cell_valid?(shot) 
  def is_shot_valid?(shot, [cell]), do: is_cell_valid?(shot) && shot != cell
  def is_shot_valid?(shot, [h | t]), do: is_shot_valid?(shot, [h]) && is_shot_valid?(shot, t)
  
  @doc """
  Function to analyse the impact of a received shot in someone's boats
  """
  @spec conseq_shots([cell], [boat]) :: atom

  def conseq_shots([shot], boats), do: if did_it_miss?(shot, boats), do: :miss, else: :hit

  def conseq_shots([shot | shots], boats) do
    
    if did_it_miss?(shot, boats) do
      :miss
    else
      boats_not_sunk = 
      effects_shots_on_boats(shots, boats)  
      |> Enum.filter( &( length(&1) != 0 ) )
      last_shot_on_boats = effects_shots_on_boats( [shot], boats_not_sunk )
      cond do
        List.flatten(last_shot_on_boats) == [] -> :end
        Enum.member?(last_shot_on_boats, []) -> :sunk
        true -> :hit
      end
    
    end
  
  end
  # SUPPORT FUNCTIONS

  @doc """
  Function to check if one shot missed
  """
  @spec did_it_miss?(cell, [boat]) :: boolean

  def did_it_miss?(shot, boats), do: not Enum.member?(List.flatten(boats), shot)

  @doc """
  Function to check if cell is inside grid
  """
  @spec is_cell_valid?(cell) :: boolean

  def is_cell_valid?({x,y}), do: Enum.member?(0..9, x) && Enum.member?(0..9, y)

  @doc """
  Function which returns the remaining cells of boats, the ones unharmed by shots
  """
  @spec effects_shots_on_boats([cell], [boat]) :: [[cell]]
  
  def effects_shots_on_boats(shots, [boat]), do: [ boat -- shots ]
  
  def effects_shots_on_boats(shots, [boat | boats]), do: effects_shots_on_boats(shots, [boat]) ++ effects_shots_on_boats(shots, boats)

end
