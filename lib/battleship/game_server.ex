defmodule Battleship.GameServer do
  use GenServer
  alias Battleship.Game

  # CLIENT FUNCTIONS
  def start_link(game_name) do
    GenServer.start_link(__MODULE__, nil, name: game_name)
  end

  def join(game_name) do
    GenServer.call(game_name, :join)
  end

  def insert_boat(game_name, boat) do
    GenServer.call(game_name, {:insert_boat, boat})
  end

  def shoot(game_name, shot) do
    GenServer.call(game_name, {:shoot, shot})
  end

  # SERVER FUNCTIONS
  def init(_) do
    {:ok, Game.new()}
  end

  def handle_call(:join, from, state) do
    {pid, _} = from

    case Game.join(pid, state) do
      {:ok, new_state} -> {:reply, {:ok, "Succesfull conection"}, new_state}
      {:error, message} -> {:reply, {:error, message}, state}
    end
  end

  def handle_call({:insert_boat, boat}, from, state) do
    {pid, _} = from
    player = Game.player(pid, state)

    case Game.insert_boat({boat, pid}, state) do
      {:error, msg} ->
        {:reply, {:error, msg}, state}

      {:ok, new_state} ->
        check_mode_players_ready(new_state)

        check_player_finish(new_state, player)
    end
  end

  def handle_call({:shoot, shot}, from, state) do
    {pid, _} = from
    player = Game.player(pid, state)

    case Game.shoot({shot, pid}, state) do
      {:error, msg} ->
        {:reply, {:error, msg}, state}

      {:ok, new_state} ->
        {active_turn, other_turn} = check_mode_after_shot(new_state, player)

        Process.send(
          new_state[Game.other_player(player)].pid,
          {other_turn, new_state[player].shots},
          []
        )

        {:reply, {active_turn, new_state[player].shots}, new_state}
    end
  end

  # PRIVATE FUNCTIONS

  defp check_mode_players_ready(state) do
    if state.mode == :player1 do
      Process.send(state.player1.pid, {:you, state.player2.boats}, [])
      Process.send(state.player2.pid, {:enemy, state.player1.boats}, [])
    else
      nil
    end
  end

  defp check_mode_after_shot(state, player) do
    cond do
      state.mode == player -> {:you, :enemy}
      state.mode == Game.other_player(player) -> {:enemy, :you}
      true -> {:you_won, :you_lost}
    end
  end

  defp check_player_finish(state, player) do
    if length(state[player].boats) == length(state.available_boats) do
      {:reply, {:full, state[player].boats}, state}
    else
      {:reply, {:ok, state[player].boats}, state}
    end
  end
end
