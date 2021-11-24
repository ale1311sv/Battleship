defmodule Battleship.Game do
  alias Battleship.Operations

  defmodule Player do
    defstruct boats: [],
              shots: [],
              pid: nil
  end

  @type cell :: {non_neg_integer(), non_neg_integer()}
  @type boat :: [cell()]
  @type state :: %{
          player1: %Player{},
          player2: %Player{},
          mode: atom(),
          available_boats: [pos_integer()]
        }

  @spec new :: state()
  def new do
    %{
      player1: %Player{},
      player2: %Player{},
      mode: :initial,
      available_boats: [5, 4, 3, 3, 2]
    }
  end

  @spec join(pid(), state()) :: {:ok, state()} | {:error, binary()}
  def join(pid, %{player1: %{pid: nil}} = state) do
    {:ok, put_in(state, [:player1, :pid], pid)}
  end

  def join(pid, %{player2: %{pid: nil}} = state) do
    state =
      state
      |> put_in([:player2, :pid], pid)
      |> Map.put(:mode, :setting)

    {:ok, state}
  end

  def join(_, _) do
    {:error, "Game is full"}
  end

  def insert_boat({boat, pid}, %{mode: :setting} = state) do
    player = player(pid, state)

    cond do
      player == :error ->
        {:error, "Player not valid"}

      not Operations.is_boat_available?(boat, state[player].boats, state.available_boats) ->
        {:error, "Boat not available"}

      not Operations.is_boat_location_valid?(boat, state[player].boats) ->
        {:error, "Location not valid"}

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
  def shoot({shot, pid}, %{mode: player} = state) when player in [:player1, :player2] do
    cond do
      player(pid, state) == :error ->
        {:error, "Player not valid"}

      player(pid, state) != player ->
        {:error, "It is not your turn"}

      not Operations.is_shot_valid?(shot, state[player].shots) ->
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

  defp both_players_ready?(state) do
    Operations.all_boats_set?(state.player1.boats, state.available_boats) &&
      Operations.all_boats_set?(state.player2.boats, state.available_boats)
  end

  defp check_start_playing(state) do
    if both_players_ready?(state) do
      Map.put(state, :mode, :player1)
    else
      state
    end
  end

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

  defp change_turn_after_shot(state) do
    player = state.mode
    shot = List.last(state[player].shots)

    if Operations.hit?(shot, state[other_player(player)].boats) do
      state
    else
      Map.put(state, :mode, other_player(player))
    end
  end

  defp player(pid, state) do
    cond do
      pid == state.player1.pid -> :player1
      pid == state.player2.pid -> :player2
      true -> :error
    end
  end

  defp other_player(:player1), do: :player2
  defp other_player(:player2), do: :player1
end
