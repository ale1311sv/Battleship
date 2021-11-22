defmodule BattleshipWeb.PlayerGameLive do
  use BattleshipWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{available_boats: [5, 4, 3, 3, 2], mode: :you})}
  end

  def render(assigns) do
    BattleshipWeb.PageView.render("player_game_live.html", assigns)
  end
end
