defmodule Battleship.Game do
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
      available_boats: [5,4,3,3,2]
    }
  end

  @spec join(pid(), map()) :: tuple()
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

  def insert_boat({boat, pid}, %{player1: %{pid: pid1}, player2: %{pid: pid2}, mode: :setting} = state) do
    {atom, other} = player(pid, pid1, pid2)
    if atom == :error do
      {atom, other}
    else
      # if is_position_valid?(boat, get_in(state, [atom, :boats])) do
      #   state =
      #     state
      #     |> put_in([atom, :boats], get_in(state, [atom, :boats]) ++ boat)

      #   if all_boats_set?(get_in(state, [atom, :boats])) do
      #     if all_boats_set?(get_in(state, [other, :boats])) do
      #       state =
      #         state
      #         |> Map.put(:mode, :p1)

      #       {:ready, state}
      #     else
      #       {:full, state}
      #     end
      #   else
      #     {:ok, state}
      #   end
      # else
      #   {:error, "Position not valid"}
      # end
    end
  end

  def insert_boat(_, _) do
    {:error, "Mode not valid"}
  end

  defp player(pid, pid1, pid2) do
    cond do
      pid == pid1 -> {:player1, :player2}
      pid == pid2 -> {:player2, :player1}
      true -> {:error, "PID not valid"}
    end
  end
end
