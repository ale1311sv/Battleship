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

  @spec mount(any, any, any) :: any

  def mount(_params, _session, socket) do
    {:ok, assign(socket, new())}
    IO.inspect(socket)
  end

  # - Events for setting state -------------------------

  @spec handle_event(<<_::104>>, map, %{
          :assigns => atom | %{:avalaible_boats => list, optional(any) => any},
          optional(any) => any
        }) :: {:noreply, map}

  def handle_event("boat_selected", %{"length" => length}, socket) do
    {:noreply, socket}
  end

  def handle_event("cell_selected", %{"row" => row, "column" => column}, socket) do
    {:noreply, socket}
  end

  # - Events for game state --------------------------

  def handle_event(_, unsigned_params, socket) do
  end

end
