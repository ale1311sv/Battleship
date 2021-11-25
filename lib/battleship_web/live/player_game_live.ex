defmodule BattleshipWeb.PlayerGameLive do
  use Phoenix.LiveView, layout: {BattleshipWeb.LayoutView, "live.html"}
  alias Battleship.Operations

  def new() do
    %{
      you: %{
        boats_left: [5, 4, 3, 3, 2],
        boats: [],
        shots: [],
        first_cell_selected: nil,
        boat_selected: nil
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

  # - Events for setting state -------------------------


  def handle_event("boat_selected", %{"length" => boat_length}, %{assigns: %{you: %{boat_selected: nil}}} = socket) do
    new_socket =
      update(socket, :you, &Map.put(&1, :boat_selected, String.to_integer(boat_length)))

    {:noreply, new_socket}
  end

  def handle_event("boat_selected", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cell_selected", _params, %{assigns: %{you: %{boat_selected: nil}, mode: :setting}} = socket) do
    {:noreply, socket}
  end


  def handle_event("cell_selected", %{"row" => row, "column" => column}, %{assigns: %{you: %{first_cell_selected: nil}, mode: :setting}} = socket) do
    cell = {String.to_integer(row), String.to_integer(column)}
    {:noreply, update(socket, :you, &Map.put(&1, :first_cell_selected, cell))}
  end

  def handle_event("cell_selected", %{"row" => row, "column" => column}, %{assigns: %{mode: :setting}} = socket) do
    cell = {String.to_integer(row), String.to_integer(column)}
    first_cell = socket.assigns.you.first_cell_selected
    length_selection = socket.assigns.you.boat_selected
      cond do
        not Operations.are_cells_valid?(first_cell, cell)->
          {:noreply, "One of the cells is out of margin"}

        not Operations.is_it_a_boat?(first_cell, cell) ->
          {:noreply, "Cells selection is illegal"}

        not Operations.are_selected_cells_intented_length?(first_cell, cell, length_selection) ->
          {:noreply, "Your boat selection was not right"}

        true ->
          boat = Operations.create_boat(first_cell, cell)

          # SEND 'boat' TO GAME
          # IF IT IS :ok DO

          socket = update_socket_with_boat(boat, socket)

          {:noreply, socket}
        end
  end


  def handle_event("cell_selected", %{"row" => row, "column" => column}, %{assigns: %{mode: :game}} = socket) do
    cell = {String.to_integer(row), String.to_integer(column)}
    shots = socket.assigns.you.shots

    if Operations.is_shot_valid?(cell, shots) do
        update_socket_with_shot(cell, socket)
        IO.inspect({:noreply, socket})
    else
        {:noreply, "The shot is not valid"}
    end
  end


  # - Events for game state --------------------------

  defp update_socket_with_boat(boat, socket) do
    length_selection = socket.assigns.you.boat_selected

    you = socket.assigns.you
          |> Map.put(:first_cell_selected, nil)
          |> Map.put(:boat_selected, nil)
          |> update_in([:boats], &(&1 ++ [boat]))
          |> update_in([:boats_left], &List.delete(&1, length_selection))

    assign(socket, :you, you)
  end

  defp update_socket_with_shot(shot, socket) do
    you = socket.assigns.you
      |> update_in([:shots], &(&1 ++ [shot]))

    assign(socket, :you, you)
  end

end
