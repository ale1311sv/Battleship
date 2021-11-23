defmodule BattleshipWeb.PlayerGameLive do
use Phoenix.LiveView, layout: {BattleshipWeb.LayoutView, "live.html"}

  def new() do
    %{
      you: %{
        available_boats: [5, 4, 3, 3, 2],
        boats: [],
        shots: [],
        first_cell_selected: {},
        boat_selected: 1
      },
      enemy: %{
        boats: [],
        shots: []
      },
      mode: :setting,
      submode: :basic
    }
  end

  def render(assigns) do
    BattleshipWeb.PageView.render("player_game_live.html", assigns)
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, new())}
  end

  def handle_event("boat_selected", %{"length" => length}, socket) do
    {:noreply, socket}
  end
end
