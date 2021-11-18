defmodule BattleshipWeb.SettingLive do
  use BattleshipWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{board_size: 10, available_boats: [{5,1}, {4,1}, {3, 2}, {2, 1}]})}
  end

end
