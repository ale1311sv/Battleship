defmodule BattleshipWeb.SettingLive do
  use BattleshipWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{board_size: 10, available_boats: [5, 4, 3, 3, 2]})}
  end

end
