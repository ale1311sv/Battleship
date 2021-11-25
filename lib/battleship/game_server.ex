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
    {:ok, Game.new}
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
    {atom, new_state} = Game.insert_boat({boat, pid}, state)
    check_mode_players_ready(new_state)
    case atom do
      :error -> {:reply, {:error, new_state}, state}
      :ok -> {:reply, {:ok, new_state[player].boats}, new_state}
    end
  end

  def handle_call({:shoot, shot}, from, state) do
    {pid, _} = from
    player = Game.player(pid, state)
    {atom, new_state} = Game.shoot({shot, pid}, state)
    check_mode_after_shot(new_state)
    case atom do
      :error -> {:reply, {:error, new_state}, state}
      :ok ->
        Process.send(new_state[Game.other_player(player)].pid, {:enemy_shots, new_state[player].shots}, :ok)
        {:reply, {:ok, new_state[player].shots}, new_state}

    end
  end

  defp check_mode_players_ready(msg) when is_binary(msg), do: nil
  defp check_mode_players_ready(state) do
    if state.mode == :player1 do
      Process.send(state.player1.pid, {:you, state.player2.boats}, :ok)
      Process.send(state.player2.pid, {:enemy, state.player1.boats}, :ok)
    else
      nil
    end
  end

  defp check_mode_after_shot(msg) when is_binary(msg), do: nil
  defp check_mode_after_shot(state) do
    if state.mode == :player1 do
      Process.send(state.player1.pid, :you, :ok)
      Process.send(state.player2.pid, :enemy, :ok)
    else
      Process.send(state.player2.pid, :you, :ok)
      Process.send(state.player1.pid, :enemy, :ok)
    end
  end
end
