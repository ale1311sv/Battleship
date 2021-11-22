defmodule Battleship.Game do
	# JOIN MODE


	# SETTING MODE


	# PLAYING MODE
	@spec make_shot(tuple(), map()) :: {atom(), term()}
	def make_shot(shot, %{mode: :initial}) do
		{:error, "You cannot shot in initial mode"}
	end

	def make_shot(shot, %{mode: :setting}) do
		{:error, "You cannot shot in setting mode"}
	end

	def make_shot(shot, %{mode: :p1} = state) do
		if shot_valid?(shot, state.player1.shots) do
			state = put_in(state, [:player1, :shots], [shot] ++ state.player1.shots)
			conseq = conseq_shots(state.player1.shots, state.player2.boats)
			{conseq, state}
		else
			{:error, state}
		end
	end

	def make_shot(shot, %{mode: :p2} = state) do
		if shot_valid?(shot, state.player2.shots) do
			state = put_in(state, [:player2, :shots], [shot] ++ state.player1.shots)
			conseq = conseq_shots(state.player1.shots, state.player1.boats)
			{conseq, state}
		else
			{:error, state}
		end
	end
end
