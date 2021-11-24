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

    IO.inspect({:noreply, new_socket})
    # List.delete(socket.assigns.available_boats, String.to_integer(length)))}
  end

  def handle_event("boat_selected", %{"length" => boat_length}, socket) do
    {:noreply, socket}
  end

  def handle_event("cell_selected", %{"row" => row, "column" => column}, %{assigns: %{you: %{boat_selected: nil}}} = socket) do
    {:noreply, socket}
  end


  def handle_event("cell_selected", %{"row" => row, "column" => column}, %{assigns: %{you: %{first_cell_selected: nil}}} = socket) do
    cell = {String.to_integer(row), String.to_integer(column)}
    {:noreply, update(socket, :you, &Map.put(&1, :first_cell_selected, cell))}
  end

  def handle_event("cell_selected", %{"row" => row, "column" => column}, socket) do
    cell = {String.to_integer(row), String.to_integer(column)}
    first_cell = socket.assigns.you.first_cell_selected
    length_selection = socket.assigns.you.boat_selected
      cond do
        not Operations.is_cell_valid?(first_cell) || not Operations.is_cell_valid?(cell) ->
          {:reply, "One of the cells is out of margin"}

        not Operations.is_it_a_boat?(first_cell, cell) ->
          {:reply, "Cells selection is illegal"}

        not Operations.are_selected_cells_intented_length?(first_cell, cell, length_selection) ->
          {:reply, "Your boat selection was not right"}

        true ->
          # second_cell_selected(cell, socket)
      end
    {:noreply, socket}
  end

  # - Events for game state --------------------------
  @doc """
  Function when is selected the first cell
  """
  defp first_cell_selected(cell, socket) do

  end

  @doc """
  Function when is selected the second cell
  """
  # defp second_cell_selected(cell, socket) do
  #   second_cell = cell
  #   is_it_a_boat?(socket.assigns.you.first_cell_selected, second_cell)
  # end
end
