defmodule BattleshipWeb.Player do
  use BattleshipWeb, :live_view
  use GenServer

  @initial_state {
    %{
    player1:
    %{
      boats: [
        [{}]
      ],
      shots: [
        {}
      ]
    },
    player2:
    %{
      boats: [
        [{}]
      ],
      shots: [
        {}
      ]
    }
  }, :setting,
  {}
}


  # def render(assigns) do
  #   BattleshipWeb.PageView.render("index.html", assigns)
  # end

@doc """
  Mount the game server
"""
def render(assigns) do
  ~H"""
  <h1> Prueba </h1>
  <%= @url %>
  """
end

def mount(params,_session, socket) do

    clave = Map.keys(params) |> Enum.at(0)
    valor = Map.get(params, clave)
    prueba = String.to_atom(valor)

    socket = assign(socket, :url, valor)

    # if connected?(socket), do: Process.send_after(self(), :update, 1000)

    case GenServer.start_link(__MODULE__,@initial_state, name: prueba) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      IO.inspect(pid)
    end

    IO.inspect(socket)

    {:ok, socket}

  end

  def handle_call({:join, player_id, pid}, _from, game) do
    cond do
      game.player1 =/ nil and game.player2 =/ nil ->
        {:reply, {:error, "Only two players are allowed"}, game}
      Enum.member?([game.player1, game.player2], player_id) ->
        {:reply, {:ok, self()}, game}
      true ->
        Process.monitor(pid)

    end
  end

    # def init(state) do
    #   {:ok, state}
    # end

    # def handle_call(:pop, _from, socket) do
    #   {:reply, :hello, socket}
    # end

    def handle_event("insert_boat",_,socket) do
    #   case Game do
    #     {{:valid, new_state}, new_state} ->

    #     {{:no_valid, old_state}, old_state}  ->

    #   end
    end


  def handle_info(:time, state) do
    # GenServer.call()

  end

  defp time_info() do
    # Process.send_after()
  end

  # defp add_player(%__MODULE__)

end
