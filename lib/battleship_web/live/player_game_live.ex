defmodule BattleshipWeb.PlayerGameLive do
  use Phoenix.LiveView, layout: {BattleshipWeb.LayoutView, "live.html"}
  alias Battleship.Operations
  alias Battleship.GameServer
  alias BattleshipWeb.SettingStruct
  alias BattleshipWeb.PlayingStruct
  alias BattleshipWeb.GameOverStruct

  def new(game_name) do
    %{
      game_name: game_name,
      mode: nil,
      state: nil
    }
  end

  def render(assigns) do
    BattleshipWeb.PageView.render("player_game_live.html", assigns)
  end

  def mount(%{"id" => id}, _session, socket) do
    game_name = String.to_atom(id)
    socket = assign(socket, new(game_name))
    {:ok, _} = GameServer.start_link(socket.assigns.game_name)

    case GameServer.join(socket.assigns.game_name) do
      {:ok, available_boats} ->
        {:ok, assign(socket, mode: :setting, state: %SettingStruct{available_boats: available_boats, boats_left: available_boats})}

      {:error, _msg} -> {:ok, assign(socket, mode: :not_allowed)}
    end
  end

  # - Events for setting state -------------------------

  def handle_event(
        "boat_selected",
        %{"length" => boat_length},
        %{assigns: %{mode: :setting, state: %SettingStruct{first_cell_selected: nil}}} = socket
      ) do
    state = %{socket.assigns.state | boat_selected: String.to_integer(boat_length)}

    {:noreply, assign(socket, state)}
  end

  def handle_event("boat_selected", _params, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "cell_selected",
        _params,
        %{assigns: %{mode: :setting, state: %SettingStruct{boat_selected: nil}}} = socket
      ) do
    {:noreply, socket}
  end

  def handle_event(
        "cell_selected",
        %{"row" => row, "column" => column},
        %{assigns: %{mode: :setting, state: %SettingStruct{first_cell_selected: nil}}} = socket
      ) do
    cell = {String.to_integer(row), String.to_integer(column)}
    state = %{socket.assigns.state | first_cell_selected: cell}
    {:noreply, assign(socket, state)}
  end

  def handle_event(
        "cell_selected",
        %{"row" => row, "column" => column},
        %{assigns: %{mode: :setting}} = socket
      ) do
    cell = {String.to_integer(row), String.to_integer(column)}
    first_cell = socket.assigns.state.first_cell_selected
    length_selection = socket.assigns.state.boat_selected

    cond do
      not Operations.are_cells_valid?(first_cell, cell) ->
        {:noreply, socket}

      not Operations.is_it_a_boat?(first_cell, cell) ->
        {:noreply, socket}

      not Operations.are_sel_cells_intented_length?(length_selection, first_cell, cell) ->
        {:noreply, socket}

      true ->
        Operations.create_boat(first_cell, cell)
        |> insert_boat(socket)
    end
  end

  def handle_event(
        "cell_selected",
        %{"row" => row, "column" => column},
        %{assigns: %{mode: :playing}} = socket
      ) do
    cell = {String.to_integer(row), String.to_integer(column)}
    shots = socket.assigns.state.you.shots

    if Operations.is_shot_legal?(cell, shots) do
      case GameServer.shoot(socket.assigns.game_name, cell) do

        {:error, _msg} ->
          {:noreply, socket}

        {{turn, false}, shots} ->

          state =
            socket.assigns.state
            |> Map.put(:turn, turn)
            |> put_in([:you, :shots], shots)

          {:noreply, assign(socket, :state, state)}

        {{winner, true}, shots} ->

          state =
            socket.assigns.state
            |> put_in([:you, :shots], shots)

          state = %GameOverStruct{winner: winner, you: state.you, enemy: state.enemy}

          {:noreply, assign(socket, mode: :game_over, state: state)}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("cell_selected", _params, socket), do: {:noreply, socket}

  # - Handle infos ---------------------

  def handle_info({turn, enemy_boats}, %{assigns: %{mode: :setting}} = socket) do
    available_boats = socket.assigns.state.available_boats

    enemy =
      socket.assigns.state.enemy
      |> Map.put(:alive_boats, available_boats)
      |> Map.put(:boats, enemy_boats)

    you =
      socket.assigns.you
      |> Map.put(:alive_boats, available_boats)

    state = %PlayingStruct{you: you, enemy: enemy, turn: turn}

    {:noreply, assign(socket, mode: :playing, state: state)}
  end

  def handle_info(msg, %{assigns: %{mode: :playing}} = socket) do
    case msg do
      {:error, _msg} ->
        {:noreply, socket}

      {{turn, false}, shots} ->

        state =
          socket.assigns.state
          |> Map.put(:turn, turn)
          |> put_in([:enemy, :shots], shots)

        {:noreply, assign(socket, :state, state)}

      {{winner, true}, shots} ->

        state =
          socket.assigns.state
          |> put_in([:enemy, :shots], shots)

        state = %GameOverStruct{winner: winner, you: state.you, enemy: state.enemy}

        {:noreply, assign(socket, mode: :game_over, state: state)}
    end
  end


  # - Events for game state --------------------------

  defp insert_boat(boat, socket) do
    length_selection = socket.assigns.state.boat_selected

    case GameServer.insert_boat(socket.assigns.game_name, boat) do
      {:ok, boats} ->
        state =
          socket.assigns.state
          |> Map.put(:first_cell_selected, nil)
          |> Map.put(:boat_selected, nil)
          |> Map.put(:set_boats, boats)
          |> Map.update!(:boats_left, &(&1 -- [length_selection]))

        if length(socket.assigns.state.boat_left) == 0 do
          {:noreply, assign(socket, :state,  %{state | ready: true})}
        else
          {:noreply, assign(socket, :state, state)}
        end

      {:error, _msg} ->
        {:noreply, socket}
    end
  end

end
