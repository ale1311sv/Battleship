defmodule BattleshipWeb.SettingStruct do
  defstruct ready: false,
            available_boats: [],
            boats_left: [],
            set_boats: [],
            first_cell_selected: nil,
            boat_selected: nil
end

defmodule BattleshipWeb.PlayingStruct do
  defstruct turn: nil,
            you: %{
              alive_boats: [],
              boats: [],
              shots: []
            },
            enemy: %{
              alive_boats: [],
              boats: [],
              shots: []
            }
end

defmodule BattleshipWeb.GameOverStruct do
  defstruct winner: nil,
            you: %{
              alive_boats: [],
              boats: [],
              shots: []
            },
            enemy: %{
              alive_boats: [],
              boats: [],
              shots: []
            }
end
