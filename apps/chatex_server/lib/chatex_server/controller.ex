defmodule ChatexServer.Controller do
  use GenServer
  require Logger

  alias ChatexServer.User
  alias ChatexServer.User.Registry

  def start_link(name) do
    GenServer.start_link(__MODULE__, nil, name: {:global, name})
  end

  #Server callbacks

  defmodule State do
    defstruct users_by_pid: %{}, pids_by_users: %{} 

    def get_user(%State{users_by_pid: users}, pid) do
      Map.fetch(users, pid)
    end

    def get_pid(%State{pids_by_users: pids}, username) do
      Map.fetch(pids, username)
    end

    def add(state, username, pid) do
      %State{
        users_by_pid: Map.put(state.users_by_pid, pid, username),
        pids_by_users: Map.put(state.pids_by_users, username, pid)
      }
    end
  end

  def init(_) do
    {:ok, %State{}}
  end

  def handle_call({:register, username, key_phrase}, _, state) do
    user = %User{username: username, key_phrase: key_phrase}
    {:reply, Registry.register_user(:user_registry, user), state}
  end

  def handle_call({:connect, username, key_phrase}, {pid, _}, state) do
    Logger.info("User #{username} trying to connect.")

    case Registry.get_user(:user_registry, username) do
      %User{key_phrase: ^key_phrase} ->
        Logger.info("User #{username} connected: #{inspect(pid)}.")
        {:reply, :ok, State.add(state, username, pid)}
      nil -> {:reply, {:error, :unregistered}, state}
      _ ->
        {:reply, {:error, :invalid}, state}
    end
  end

  def handle_call(:ping, _, state) do
    {:reply, {:pong, self()}, state}
  end

  def handle_call({:send_private_message, to_user, message}, {pid, _}, state) do
    {:ok, username} = State.get_user(state, pid)
    case State.get_pid(state, to_user) do
      {:ok, pid} when is_pid(pid) -> 
        send(pid, {:message, username, message})
        {:reply, :ok, state}
      :error -> {:reply, {:error, :user_not_found}, state}
    end
  end

  def handle_call({:send_to_channel, channel, message}, {pid, _}, state) do
    #TODO: implement
  end
end