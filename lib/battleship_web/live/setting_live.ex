defmodule BattleshipWeb.SettingLive do
  use BattleshipWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{board_size: 10, available_boats: [5, 4, 3, 3, 2]})}
  end

  def handle_event("boat_selected", %{"length" => length}, socket) do
    {:noreply, assign(socket, :available_boats, List.delete(socket.assigns.available_boats, String.to_integer(length)))}
  end

  def render(assigns) do
    BattleshipWeb.PageView.render("setting_live.html", assigns)
  end


end
