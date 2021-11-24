defmodule Battleship.Game do
  alias Battleship.Operationsgame

  @type cell :: tuple()
  @type boat :: [[cell()]]
  @type state :: %{
          player1: %{boats: list(), shots: list(), pid: pid()},
          player2: %{boats: list(), shots: list(), pid: pid()},
          mode: atom(),
          available_boats: list()
        }

  @spec new :: %{
          available_boats: [2 | 3 | 4 | 5, ...],
          mode: :initial,
          player1: %{boats: [], pid: nil, shots: []},
          player2: %{boats: [], pid: nil, shots: []}
        }
        
  def new do
    %{
      player1: %{
        boats: [],
        shots: [],
        pid: nil
      },
      player2: %{
        boats: [],
        shots: [],
        pid: nil
      },
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

  @spec insert_boat({boat, pid()}, state) :: {atom(), state()} | {:error, binary()}
  def insert_boat(
        {boat, pid},
        %{player1: %{pid: pid1}, player2: %{pid: pid2}, mode: :setting} = state
      ) do
    {active_player, other_player} = player(pid, pid1, pid2)

    if active_player == :noplayer do
      {:error, "PID not valid"}
    else
      if Operationsgame.is_position_valid?(
           boat,
           get_in(state, [active_player, :boats]),
           state.available_boats
         ) do
        state =
          state
          |> put_in([active_player, :boats], get_in(state, [active_player, :boats]) ++ [boat])

        if Operationsgame.all_boats_set?(get_in(state, [active_player, :boats]), state.available_boats) do
          if Operationsgame.all_boats_set?(get_in(state, [other_player, :boats]), state.available_boats) do
            state =
              state
              |> Map.put(:mode, :p1)

            {:ready, state}
          else
            {:full, state}
          end
        else
          {:ok, state}
        end
      else
        {:error, "Position not valid"}
      end
    end
  end
  
  def insert_boat(_, _) do
    {:error, "Mode not valid"}
  end

  defp player(pid, pid1, pid2) do
    cond do
      pid == pid1 -> {:player1, :player2}
      pid == pid2 -> {:player2, :player1}
      true -> {:noplayer, "PID not valid"}
    end
  end

  # PLAYING MODE
	@spec make_shot(tuple(), map()) :: {atom(), term()}

  def make_shot({_shot, pid}, %{mode: :p1} = state) when state.player2.pid == pid, do: {:error, "Is not your turn"}
	def make_shot({shot, pid}, %{mode: :p1} = state) when state.player1.pid == pid do
    {message, state} = insert_shot(shot, state)
    cond do
      message == :end -> {message, Map.put(state, :mode, :game_over)}
      message == :miss -> {message, Map.put(state, :mode, :p2)}
      true -> {message, state}
    end
  end

  def make_shot({_shot, pid}, %{mode: :p2} = state) when state.player1.pid == pid, do: {:error, "Is not your turn"}
	def make_shot({shot, pid}, %{mode: :p2} = state) when state.player2.pid == pid do
    {message, state} = insert_shot(shot, state)
    cond do
      message == :end -> {message, Map.put(state, :mode, :game_over)}
      message == :miss -> {message, Map.put(state, :mode, :p1)}
      true -> {message, state}
    end
  end

  def make_shot( _, %{mode: _}), do: {:error, "You cannot shot in this mode"}


  def insert_shot(shot, state) do
    turn = turn_of(state.mode)
    if Operationsgame.is_shot_valid?(shot, state[List.first(turn)].shots) do
      state = put_in(state, [List.first(turn), :shots], [shot] ++ state[List.first(turn)].shots)
      conseq = Operationsgame.conseq_shots(state[List.first(turn)].shots, state[List.last(turn)].shots)
      {conseq, state}
    else
      {:error, "This shots is not allowed"}
    end
  end

  def turn_of(mode) do
    case {:mode, mode} do
      {:mode, :p1} -> [:player1, :player2]
      {:mode, :p2} -> [:player2, :player1]
    end
  end
end
