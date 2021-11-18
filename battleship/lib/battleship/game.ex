defmodule Game do
  use GenServer

  #callbacks

  def init(state) do
    {:ok, state}
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
	def handle_call({:insert_boat, list}, _from, {_, :setting} = old_state) do
		#if position_is_valid? do
			#new_state =	#insert_boat(old_state,list)
			#if all_boats_in_player? do
				#if all_boats_in? do
					#{map, _} = new_state
					#change_state = {map, :p1}
					#{:reply, {:p1, change_state}, change_state}
				#else
					#{:reply, {:full, new_state}, new_state}
				#end
			#else
				#{:reply, {:setting, new_state}, new_state}
			#end
		# else
			#{:reply, {:no_valid, old_state}, old_state}
		# end
	end


	@doc """
	When all the boats(both players) are ready, it replies to the player who set first the boats that the game is ready
	"""
	def handle_call(:full_all?, _from, {_, atom} =state) do
		# if atom == :setting do
		# 	{:reply, false, state}
		# else
		# 	{:reply, true, state}
		# end
	end




end
