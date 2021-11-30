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
      state: nil,
      info: ""
    }
  end

  def render(assigns) do
    BattleshipWeb.PageView.render("player_game_live.html", assigns)
  end

  def mount(%{"id" => id}, _session, socket) do
    game_name = String.to_atom(id)
    socket = assign(socket, new(game_name))
    GameServer.start_link(socket.assigns.game_name)

    case GameServer.join(socket.assigns.game_name) do
      {:ok, available_boats} ->
        {:ok,
         assign(socket,
           mode: :setting,
           state: %SettingStruct{available_boats: available_boats, boats_left: available_boats},
           info: "CLICK A BOAT!"
         )}

      {:error, _msg} ->
        {:ok, assign(socket, mode: :not_allowed)}
    end
  end

  # - Events for setting state -------------------------

  def handle_event(
        "boat_selected",
        %{"length" => boat_length},
        %{assigns: %{mode: :setting, state: %SettingStruct{first_cell_selected: nil}}} = socket
      ) do
    state = %{socket.assigns.state | boat_selected: String.to_integer(boat_length)}

    {:noreply, assign(socket, state: state, info: "NOW, CLICK A CELL!")}
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
    {:noreply, assign(socket, state: state, info: "SET YOUR BOAT CLICKING ANOTHER CELL!")}
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

      not Operations.are_sel_cells_intended_length?(length_selection, first_cell, cell) ->
        {:noreply, "Cells selection doesn't match expected length for boat"}

      true ->
        Operations.create_boat(first_cell, cell)
        |> insert_boat(socket)
    end
  end

  def handle_event(
        "cell_selected",
        %{"row" => row, "column" => column, "player" => "enemy"},
        %{assigns: %{mode: :playing}} = socket
      ) do
    cell = {String.to_integer(row), String.to_integer(column)}
    shots = socket.assigns.state.you.shots

    if Operations.is_shot_legal?(cell, shots) do
      case GameServer.shoot(socket.assigns.game_name, cell) do
        {:error, _msg} ->
          {:noreply, socket}

        {turn, false, shots} ->
          socket =
            socket
            |> insert_shot(shots, turn, :you)
            |> update_alive_boats(:enemy)
            |> update_info_panel(turn)

          {:noreply, socket}

        {winner, true, shots} ->
          you =
            socket.assigns.state.you
            |> Map.put(:shots, shots)

          state = %GameOverStruct{winner: winner, you: you, enemy: socket.assigns.state.enemy}

          {:noreply, assign(socket, mode: :game_over, state: state, info: "")}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("cell_selected", _params, socket), do: {:noreply, socket}

  # - Handle infos ---------------------

  def handle_info({turn, enemy_boats}, %{assigns: %{mode: :setting}} = socket) do
    available_boats = socket.assigns.state.available_boats
    state = %PlayingStruct{}

    enemy =
      state.enemy
      |> Map.put(:alive_boats, available_boats)
      |> Map.put(:boats, enemy_boats)

    you =
      state.you
      |> Map.put(:alive_boats, available_boats)
      |> Map.put(:boats, socket.assigns.state.set_boats)

    state = %PlayingStruct{you: you, enemy: enemy, turn: turn}

    info =
      if turn == :you,
        do: "IT'S YOUR TURN! CLICK A CELL TO SHOOT",
        else: "GAME BEGINS. IT'S ENEMY'S TURN."

    {:noreply, assign(socket, mode: :playing, state: state, info: info)}
  end

  def handle_info(msg, %{assigns: %{mode: :playing}} = socket) do
    state = %GameOverStruct{}

    case msg do
      {:error, _msg} ->
        {:noreply, socket}

      {turn, false, shots} ->
        socket =
          socket
          |> insert_shot(shots, turn, :enemy)
          |> update_alive_boats(:you)
          |> update_info_panel(turn)

        {:noreply, socket}

      {winner, true, shots} ->
        enemy =
          socket.assigns.state.enemy
          |> Map.put(:shots, shots)

        state = %GameOverStruct{winner: winner, you: state.you, enemy: enemy}

        {:noreply, assign(socket, mode: :game_over, state: state, info: "")}
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

        if length(state.boats_left) == 0 do
          {:noreply, assign(socket, state: %{state | ready: true}, info: "")}
        else
          {:noreply, assign(socket, state: state, info: "CLICK A BOAT!")}
        end

      {:error, _msg} ->
        {:noreply, socket}
    end
  end

  defp insert_shot(socket, shots, turn, :you) do
    you =
      socket.assigns.state.you
      |> Map.put(:shots, shots)

    state =
      socket.assigns.state
      |> Map.put(:turn, turn)
      |> Map.put(:you, you)

    assign(socket, state: state)
  end

  defp insert_shot(socket, shots, turn, :enemy) do
    enemy =
      socket.assigns.state.enemy
      |> Map.put(:shots, shots)

    state =
      socket.assigns.state
      |> Map.put(:turn, turn)
      |> Map.put(:enemy, enemy)

    assign(socket, state: state)
  end

  defp update_alive_boats(socket, :you) do
    sunk_boats =
      Operations.sunk_boats(socket.assigns.state.enemy.shots, socket.assigns.state.you.boats)
      |> Enum.map(&length/1)

    alive_boats = socket.assigns.state.you.alive_boats -- sunk_boats

    you =
      socket.assigns.state.you
      |> Map.put(:alive_boats, alive_boats)

    state =
      socket.assigns.state
      |> Map.put(:you, you)

    assign(socket, :state, state)
  end

  defp update_alive_boats(socket, :enemy) do
    sunk_boats =
      Operations.sunk_boats(socket.assigns.state.you.shots, socket.assigns.state.enemy.boats)
      |> Enum.map(&length/1)

    alive_boats = socket.assigns.state.enemy.alive_boats -- sunk_boats

    enemy =
      socket.assigns.state.enemy
      |> Map.put(:alive_boats, alive_boats)

    state =
      socket.assigns.state
      |> Map.put(:enemy, enemy)

    assign(socket, :state, state)
  end

  defp update_info_panel(socket, :you) do
    you_shots = socket.assigns.state.you.shots
    enemy_boats = socket.assigns.state.enemy.boats
    last_shot_result = Operations.last_shot_result(you_shots, enemy_boats)

    case last_shot_result do
      :miss -> assign(socket, info: "IT'S YOUR TURN! CLICK A CELL TO SHOOT.")
      :hit -> assign(socket, info: "IT WAS A HIT! SHOOT AGAIN.")
      :sunk -> assign(socket, info: "GREAT! YOU SANK A BOAT. SHOOT AGAIN.")
    end
  end

  defp update_info_panel(socket, :enemy) do
    you_shots = socket.assigns.state.you.shots

    if you_shots == [],
      do: assign(socket, info: "IT'S ENEMY'S TURN"),
      else: assign(socket, info: "OH, A MISS! IT'S ENEMY'S TURN")
  end
end
