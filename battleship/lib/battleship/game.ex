defmodule Game do
  use GenServer

  #callbacks

  def init(state) do
    {:ok, state}
  end

	@doc """
	The second process do not create the process Game so we need to store the PID2 in the tuple_pid
	"""
	@type state :: {term(), atom(), tuple()}
	@spec handle_cast(request :: term(), state :: term()) ::
  {:noreply, new_state :: state()}

	def handle_cast({:join, pid}, {map, atom, tuple_pid}) do
		new_tuple_pid = get_pid(tuple_pid, pid)
		new_state = {map, atom, new_tuple_pid}
		{:noreply, new_state}
	end

	@doc """
		It checks the position of the boat.
			If it`s valid(true)
			-> set new_state and check if all the boats of the player are set
				If true
					->check if all the boats(both players) are set
						If true
							-> {:reply, {:p1, change_state}, change_state}
						else
							-> {:reply, {:full, new_state}, new_state}
				else
					-> {:reply, {:setting, new_state}, new_state}
			else
				-> {:reply, {:no_valid, old_state}, old_state}
	"""
	@type from() :: {pid(), tag :: term()}
	@spec handle_call(request :: term(), from(), state) :: {:reply, reply, new_state:: state()}
	when reply: tuple() | boolean()

	def handle_call({:insert_boat, list}, from, {map, :setting, tuple_pid} = old_state) do
		"""
		player = player(tuple_pid, from)
		if position_is_valid?(old_state, list, player) do
			new_state =	insert_boat(old_state, list, player)
			if all_boats_in_player?(new_state, player) do
				if all_boats_in?(new_state) do
					{map, _} = new_state
					change_state = {map, :p1}
					{:reply, {:p1, change_state, player}, change_state}
				else
					{:reply, {:full, new_state, player}, new_state}
				end
			else
				{:reply, {:setting, new_state, player}, new_state}
			end
		else
			{:reply, {:no_valid, old_state, player}, old_state}
		end
		"""
	end


	@doc """
	When all the boats(both players) are set, it replies to the player who set first the boats that the game is ready
	"""
	def handle_call(:full_all?, _from, {_, atom, _} = state) do
		"""
		if atom == :setting do
			{:reply, false, state}
		else
			{:reply, true, state}
		end
		"""
	end

	#private functions

	@spec get_pid(tuple_pid :: tuple(), pid()) :: tuple()

	defp get_pid(tuple_pid, pid) do
		Tuple.append(tuple_pid,pid)
	end

	@spec player(tuple(), tuple()) :: atom()

	defp player({pid1, pid2}, {pid, _}) do
		cond do
			pid == pid1 -> :player1
			pid == pid2 -> :player2
		end
	end

end
