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
end
