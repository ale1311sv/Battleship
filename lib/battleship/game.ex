defmodule Battleship.Game do
  alias Battleship.Operations

  @type cell :: {non_neg_integer(), non_neg_integer()}
  @type boat :: [cell()]
  @type state :: %{
          player1: %{boats: [], shots: [], pid: term()},
          player2: %{boats: [], shots: [], pid: term()},
          mode: atom(),
          available_boats: [pos_integer()]
        }

  # INITIAL MODE

  @spec new :: state()
  def new do
    %{
      player1: %{boats: [], shots: [], pid: nil},
      player2: %{boats: [], shots: [], pid: nil},
      mode: :initial,
      available_boats: [2, 2]
    }
  end

  @spec join(pid(), state()) :: {:ok, state()} | {:error, binary()}
  def join(_pid, %{player1: %{pid: nil}} = state) do
    {:ok, put_in(state, [:player1, :pid], :ready)}
  end

  def join(pid, %{player1: %{pid: :ready}} = state) do
    {:ok, put_in(state, [:player1, :pid], pid)}
  end

  def join(_pid, %{player2: %{pid: nil}} = state) do
    {:ok, put_in(state, [:player2, :pid], :ready)}
  end

  def join(pid, %{player2: %{pid: :ready}} = state) do
    state =
      state
      |> put_in([:player2, :pid], pid)
      |> Map.put(:mode, :setting)

    {:ok, state}
  end

  def join(_, _) do
    {:error, "Game is full"}
  end

  # SETTING MODE
  def insert_boat({boat, pid}, %{mode: :setting} = state) do
    player = player(pid, state)

    cond do
      player == :error ->
        {:error, "Player not valid"}

      not Operations.is_boat_available?(boat, state[player].boats, state.available_boats) ->
        {:error, "Boat not available"}

      not Operations.is_boat_location_legal?(boat, state[player].boats) ->
        {:error, "Location not legal"}

      true ->
        state =
          state
          |> put_in([player, :boats], state[player].boats ++ [boat])
          |> check_start_playing()

        {:ok, state}
    end
  end

  def insert_boat(_, _) do
    {:error, "Mode not valid"}
  end

  # PLAYING MODE
  @spec shoot({cell, term()}, state) :: {:error, binary} | {:ok, state}
  def shoot({shot, pid}, %{mode: player} = state) when player in [:player1, :player2] do
    cond do
      player(pid, state) == :error ->
        {:error, "Player not valid"}

      player(pid, state) != player ->
        {:error, "It is not your turn"}

      not Operations.is_shot_legal?(shot, state[player].shots) ->
        {:error, "Not valid shot"}

      true ->
        state =
          state
          |> update_in([player, :shots], &(&1 ++ [shot]))
          |> change_turn_after_shot()
          |> check_end_game()

        {:ok, state}
    end
  end

  def shoot(_, _), do: {:error, "You cannot shot in this mode"}

  # OTHER NECESARY FUNCTIONS

  @spec player(term, state) :: :player1 | :player2 | :error
  def player(pid, state) do
    cond do
      pid == state.player1.pid -> :player1
      pid == state.player2.pid -> :player2
      true -> :error
    end
  end

  def other_player(:player1), do: :player2
  def other_player(:player2), do: :player1

  # PRIVATE FUNCTIONS

  @spec both_players_ready?(state) :: boolean
  defp both_players_ready?(state) do
    Operations.all_boats_set?(state.player1.boats, state.available_boats) &&
      Operations.all_boats_set?(state.player2.boats, state.available_boats)
  end

  @spec check_start_playing(state) :: state
  defp check_start_playing(state) do
    if both_players_ready?(state) do
      Map.put(state, :mode, :player1)
    else
      state
    end
  end

  @spec check_end_game(state) :: state
  defp check_end_game(state) do
    player = state.mode
    shots = state[player].shots
    boats = state[other_player(player)].boats

    if Operations.is_game_end?(shots, boats) do
      Map.put(state, :mode, :game_over)
    else
      state
    end
  end

  @spec change_turn_after_shot(state) :: state
  defp change_turn_after_shot(state) do
    player = state.mode
    shot = List.last(state[player].shots)

    if Operations.hit?(shot, state[other_player(player)].boats) do
      state
    else
      Map.put(state, :mode, other_player(player))
    end
  end
end
