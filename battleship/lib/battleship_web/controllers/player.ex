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
  }, :setting
}

@doc """
  Mount the game server
"""

def mount(params,_session, socket) do

    socket = assign(socket, :game_name, 0)
    clave = Map.keys(params) |> Enum.at(0)
    valor = Map.get(params, clave)
    prueba = String.to_atom(valor)

    socket = assign(socket, :url, valor)

    case GenServer.start_link(__MODULE__,@initial_state, name: prueba) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      IO.inspect(pid)
    end

    IO.inspect(socket)

    {:ok, socket}

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

  def render(assigns) do
    ~L"""
    <h1> Hola </h1>
    <%= @game_name %>
    """
  end

  def handle_info(:time, state) do
    # GenServer.call()

  end

  defp time_info() do
    # Process.send_after()
  end


end
