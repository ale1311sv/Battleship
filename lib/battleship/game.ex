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
      mode: :initial
    }
  end

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

  def insert_boat(boat, %{player1: %{boats: boats_list}} = state, pid)
      when state.player1.pid == pid do
    # if is_position_valid?(boat, boats_list) do
    #   state =
    #     state
    #     |> put_in([:player1, :boats], state.player1.boats ++ boat)

    #   if all_boats_in_player?(get_in(state, [:player1, :boats])) do
    #     if all_boats_in?(get_in(state, [:player1, :boats]), get_in(state, [:player2, :boats])) do
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
    #   {:error, "Position no valid"}
    # end
  end

  def insert_boat(boat, %{player2: %{boats: boats_list}} = state, pid)
      when state.player2.pid == pid do
    # if is_position_valid?(boat, boats_list) do
    #   state =
    #     state
    #     |> put_in([:player1, :boats], state.player2.boats ++ boat)

    #   if all_boats_in_player?(get_in(state, [:player2, :boats])) do
    #     if all_boats_in?(get_in(state, [:player1, :boats]), get_in(state, [:player2, :boats])) do
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
    #   {:error, "Position no valid"}
    # end
  end
end
