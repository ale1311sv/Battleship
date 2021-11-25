defmodule BattleshipWeb.PlayerGameLive do
  use Phoenix.LiveView, layout: {BattleshipWeb.LayoutView, "live.html"}
  alias Battleship.Operations
  alias Battleship.GameServer

  def new(game_name) do
    %{
      game_name: game_name,
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
      mode: nil,
      submode: :basic
    }
  end

  def render(assigns) do
    BattleshipWeb.PageView.render("player_game_live.html", assigns)
  end

  def mount(params, _session, socket) do
    game_name = Map.get(params, "id") |> String.to_atom()
    socket = assign(socket, new(game_name))
    GameServer.start_link(socket.assigns.game_name)

    case GameServer.join(socket.assigns.game_name) do
      {:ok, _msg} -> {:ok, assign(socket, :mode, :setting)}
      {:error, _msg} -> {:ok, assign(socket, :mode, :not_allowed)}
    end
  end

  # - Events for setting state -------------------------

  def handle_event(
        "boat_selected",
        %{"length" => boat_length},
        %{assigns: %{you: %{boat_selected: nil}}} = socket
      ) do
    new_socket =
      update(socket, :you, &Map.put(&1, :boat_selected, String.to_integer(boat_length)))

    {:noreply, new_socket}
  end

  def handle_event("boat_selected", _params, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "cell_selected",
        _params,
        %{assigns: %{you: %{boat_selected: nil}, mode: :setting}} = socket
      ) do
    {:noreply, socket}
  end

  def handle_event(
        "cell_selected",
        %{"row" => row, "column" => column},
        %{assigns: %{you: %{first_cell_selected: nil}, mode: :setting}} = socket
      ) do
    cell = {String.to_integer(row), String.to_integer(column)}
    {:noreply, update(socket, :you, &Map.put(&1, :first_cell_selected, cell))}
  end

  def handle_event(
        "cell_selected",
        %{"row" => row, "column" => column},
        %{assigns: %{mode: :setting}} = socket
      ) do
    cell = {String.to_integer(row), String.to_integer(column)}
    first_cell = socket.assigns.you.first_cell_selected
    length_selection = socket.assigns.you.boat_selected

    cond do
      not Operations.are_cells_valid?(first_cell, cell) ->
        {:noreply, "One of the cells is out of margin"}

      not Operations.is_it_a_boat?(first_cell, cell) ->
        {:noreply, "Cells selection is illegal"}

      not Operations.are_sel_cells_intented_length?(length_selection, first_cell, cell) ->
        {:noreply, "Cells selection doesn't match expected length for boat"}

      true ->
        boat = Operations.create_boat(first_cell, cell)

        case GameServer.insert_boat(socket.assigns.game_name, boat) do
          {:ok, boats} ->
            you =
              socket.assigns.you
              |> Map.put(:first_cell_selected, nil)
              |> Map.put(:boat_selected, nil)
              |> Map.put(:boats, boats)
              |> Map.update!(:boats_left, &(&1 -- [length_selection]))

            {:noreply, assign(socket, :you, you)}

          {:error, msg} ->
            {:noreply, msg}
        end
    end
  end

  def handle_event(
        "cell_selected",
        %{"row" => row, "column" => column},
        %{assigns: %{mode: :game}} = socket
      ) do
    cell = {String.to_integer(row), String.to_integer(column)}
    shots = socket.assigns.you.shots

    if Operations.is_shot_valid?(cell, shots) do
      update_socket_with_shot(cell, socket)
      {:noreply, socket}
    else
      {:noreply, "The shot is not valid"}
    end
  end

  # - Handle infos ---------------------

  def handle_info({msg, enemy_boats}, socket) do
    socket =
      socket
      |> assign(:mode, :game)
      |> assign(:submode, msg)
      |> assign([:enemy, :boats], enemy_boats)

    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    socket =
      socket
      |> assign(:submode, msg)

    {:noreply, socket}
  end

  # - Events for game state --------------------------

  # defp update_socket_with_boat(boat, socket) do
  #   length_selection = socket.assigns.you.boat_selected

  #   you = socket.assigns.you
  #         |> Map.put(:first_cell_selected, nil)
  #         |> Map.put(:boat_selected, nil)
  #         |> update_in([:boats], &(&1 ++ [boat]))
  #         |> update_in([:boats_left], &List.delete(&1, length_selection))

  #   assign(socket, :you, you)
  # end

  defp update_socket_with_shot(shot, socket) do
    you =
      socket.assigns.you
      |> update_in([:shots], &(&1 ++ [shot]))

    assign(socket, :you, you)
  end
end
