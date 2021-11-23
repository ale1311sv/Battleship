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

  # PLAYING MODE
	@spec make_shot(tuple(), map()) :: {atom(), term()}

  def make_shot({shot, pid}, %{mode: :p1} = state) when state.player2.pid == pid, do: {:error, "Is not your turn"}
	def make_shot({shot, pid}, %{mode: :p1} = state) when state.player1.pid == pid do
    {message, state} = insert_shot(shot, state)
    cond do
      message == :end -> {message, Map.put(state, :mode, :game_over)}
      message == :miss -> {message, Map.put(state, :mode, :p2)}
      true -> {message, state}
    end
  end

  def make_shot({shot, pid}, %{mode: :p2} = state) when state.player1.pid == pid, do: {:error, "Is not your turn"}
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
    # turn = turn_of(state.mode)
    # if shot_valid?(shot, state[List.first(turn)].shots) do
    #   state = put_in(state, [List.first(turn), :shots], [shot] ++ state[List.first(turn)].shots)
    #   conseq = conseq_shots(state[List.first(turn)].shots, state.List.last(turn).shots)
    #   {conseq, state}
    # else
    #   {:error, "This shots is not allowed"}
    # end
  end

  def turn_of(mode) do
    case {:mode, mode} do
      {:mode, :p1} -> [:player1, :player2]
      {:mode, :p2} -> [:player2, :player1]
    end
  end
end
