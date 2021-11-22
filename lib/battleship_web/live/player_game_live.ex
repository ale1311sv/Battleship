defmodule BattleshipWeb.PlayerGameLive do
  use Phoenix.LiveView

  @spec new :: %{
          enemy: %{boats: [], shots: []},
          mode: :setting,
          you: %{
            avalaible_boats: [1 | 2 | 3 | 4 | 5, ...],
            boat_selected: nil,
            boats: [],
            first_cell_selected: {},
            shots: []
          }
        }
  def new() do
    %{
      you: %{
        avalaible_boats: [5, 4, 3, 3, 2, 1],
        boats: [],
        shots: [],
        first_cell_selected: {},
        boat_selected: nil
      },
      enemy: %{
        boats: [],
        shots: []
      },
      mode: :setting
    }
  end

  def render(assigns) do
    BattleshipWeb.PageView.render("player_game_live.html", assigns)
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, new())}
    IO.inspect(socket)
  end

  @spec handle_event(<<_::104>>, map, %{
          :assigns => atom | %{:avalaible_boats => list, optional(any) => any},
          optional(any) => any
        }) :: {:noreply, map}
  def handle_event("boat_selected", %{"length" => length}, socket) do
    {:noreply, socket}
  end

end
