defmodule ChatexServer.Controller do
  use GenServer
  require Logger

  alias ChatexServer.User
  alias ChatexServer.Channel

  def start_link(name) do
    GenServer.start_link(__MODULE__, nil, name: {:global, name})
  end

  #Server callbacks

  defmodule State do
    defstruct users_by_pid: %{},
              pids_by_users: %{},
              refs: %{}

    def get_user(%State{users_by_pid: users}, pid) do
      Map.fetch(users, pid)
    end

    def get_pid(%State{pids_by_users: pids}, username) do
      Map.fetch(pids, username)
    end

    def add(state, username, pid) do
      ref = Process.monitor(pid)
      %State{
        users_by_pid: Map.put(state.users_by_pid, pid, username),
        pids_by_users: Map.put(state.pids_by_users, username, pid),
        refs: Map.put(state.refs, ref, pid)
      }
    end

    def delete_by_ref(state, ref) do
      pid = Map.fetch(state.refs, ref)
      user = get_user(state, pid)
      %State{
        users_by_pid: Map.delete(state.users_by_pid, pid),
        pids_by_users: Map.delete(state.pids_by_users, user),
        refs: Map.delete(state.refs, ref)
      }
    end
  end

  def init(_) do
    Logger.debug("Initializing Controller")
    {:ok, %State{}}
  end

  def handle_call({:register, username, key_phrase}, _, state) do
    user = %User{username: username, key_phrase: key_phrase}
    {:reply, User.Registry.register_user(:user_registry, user), state}
  end

  def handle_call({:connect, username, key_phrase}, {pid, _}, state) do
    case User.Registry.get_user(:user_registry, username) do
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

  def handle_call({:user_status, username}, {_pid, _}, state) do
    res = 
      case State.get_pid(state, username) do
        {:ok, _} -> {:ok, :online}
        :error ->
          case User.Registry.get_user(:user_registry, username) do
            %User{username: ^username} -> {:ok, :offline}
            _ -> {:error, :user_not_found}
          end
      end
    {:reply, res, state}
  end

  def handle_call({:send_private_message, to_user, message}, {pid, _}, state) do
    check_user_connected_and_do(state, pid, fn(username) ->
      case State.get_pid(state, to_user) do
          {:ok, pid} when is_pid(pid) ->
            send(pid, {:message, username, message})
            {:reply, :ok, state}
          :error -> {:reply, {:error, :user_not_found}, state}
        end
    end)
  end

  def handle_call({:create_channel, name}, {pid, _}, state) do
    check_user_connected_and_do(state, pid, fn(username) ->
      channel = %Channel{name: name, owner: username}
      {:reply, Channel.Registry.create(:channel_registry, channel), state}
    end)
  end

  def handle_call({:delete_channel, name}, {pid, _}, state) do
    check_user_connected_and_do(state, pid, fn(username) ->
      with {:ok, channel} <- Channel.Registry.get(:channel_registry, name),
           ^username <- Channel.get_owner(channel) do
        {:reply, Channel.Registry.delete(:channel_registry, name), state}
      else
        err -> {:reply, err, state}
      end
    end)
  end

  def handle_call({:join_channel, name}, {pid, _}, state) do
    check_user_connected_and_do(state, pid, fn(username) ->
      with {:ok, channel} <- Channel.Registry.get(:channel_registry, name) do
        Channel.add_user(channel, username, pid)
        {:reply, :ok, state}
      else
        :error -> {:reply, {:error, :channel_not_found}, state}
      end
    end)
  end

  def handle_call({:get_channel_users, name}, {pid, _}, state) do
    check_user_connected_and_do(state, pid, fn(_) ->
      with {:ok, channel} <- Channel.Registry.get(:channel_registry, name) do
        {:reply, Channel.get_users(channel) |> Map.keys, state}
      else
        :error -> {:reply, {:error, :channel_not_found}, state}
      end
    end)
  end

  def handle_call({:send_to_channel, name, message}, {pid, _}, state) do
     check_user_connected_and_do(state, pid, fn(username) ->
      with {:ok, channel} <- Channel.Registry.get(:channel_registry, name) do
        Channel.send_message(channel, username, message)
        {:reply, :ok, state}
      else
        :error -> {:reply, {:error, :channel_not_found}, state}
      end
    end)
  end

  def handle_call({:get_history, channel_name}, {pid, _}, state) do
    check_user_connected_and_do(state, pid, fn(_) ->
      with {:ok, channel} <- Channel.Registry.get(:channel_registry, channel_name) do
        {:reply, Channel.get_messages(channel), state}
      else
        :error -> {:reply, {:error, :channel_not_found}, state}
      end
    end)
  end

  def handle_call(_, _, state) do
    {:reply, {:error, :command_not_found}, state}
  end

  defp check_user_connected_and_do(state, pid, func) do
    case State.get_user(state, pid) do
      {:ok, username} -> func.(username)
      :error -> {:reply, {:error, :not_connected}, state}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    {:noreply, State.delete_by_ref(state, ref)}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end