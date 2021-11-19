defmodule BattleshipWeb.Main do
  use BattleshipWeb, :live_view

  def mount(_params,_session, socket) do
  {:ok, socket}
  end

  def handle_event("random_room", _params, socket) do
  random_room = "/game/" <> "partida1"
  {:noreply, push_redirect(socket, to: random_room)}
  end

  def render(assigns) do
    ~L"""
    <h1> Hola </h1>
    <button phx-click="random_room"></button>
    """
  end
end
