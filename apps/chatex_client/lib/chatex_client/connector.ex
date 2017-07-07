defmodule ChatexClient.Connector do
  use GenServer

  require Logger

  @server_name Application.get_env(:chatex_client, :server_name, :chatex_server_controller)

  def start_link(name) do
    Logger.debug("Starting connector with name #{name}")
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def register(connector, username, key_phrase) do
    GenServer.call(connector, {:register, username, key_phrase})
  end

  def connect(connector, username, key_phrase) do
    GenServer.call(connector, {:connect, username, key_phrase})
  end

  def ping(connector) do
    GenServer.call(connector, :ping)
  end

  def send_message(connector, user_or_channel, message) do
    GenServer.cast(connector, {:message, user_or_channel, message})
  end

  def call_command(connector, command) do
    GenServer.call(connector, command)
  end

  # Server callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:message, %{username: to_user}, message}, user) do
    GenServer.call({:global, @server_name}, {:send_private_message, to_user, message})
    {:noreply, user}
  end
  def handle_cast({:message, %{channel: channel}, message}, user) do
    GenServer.call({:global, @server_name}, {:send_to_channel, channel, message})
    {:noreply, user}
  end

  def handle_call({:register, username, key_phrase}, _, _) do
    case GenServer.call({:global, @server_name}, {:register, username, key_phrase}) do
      :ok -> {:reply, :ok, %{}}
      {:error, _} = err -> {:reply, err, %{}}
    end
  end

  def handle_call({:connect, _, _}, _, %{username: _} = state) do 
    {:reply, {:error, :already_connected}, state}
  end
  def handle_call({:connect, username, key_phrase}, _, %{}) do
    case GenServer.call({:global, @server_name}, {:connect, username, key_phrase}) do
      # Removed key_phrase from state
      :ok -> {:reply, :ok, %{username: username}}
      {:error, _} = err -> {:reply, err, %{}}
    end
  end

  def handle_call(:ping, _, user) do
    {:reply, GenServer.call({:global, @server_name}, :ping), user}
  end

  def handle_call({:create_channel, _name}, _, state) do
    IO.puts("Not implemented")
    {:reply, :not_implemented, state}
  end

  def handle_call({:delete_channel, _name}, _, state) do
    IO.puts("Not implemented")
    {:reply, :not_implemented, state}
  end

  def handle_call({%{username: _to_user}, :get_history}, state) do
    IO.puts("Not implemented")
    {:reply, :not_implemented, state}
  end

  def handle_call({%{channel: _channel}, :get_history}, state) do
    IO.puts("Not implemented")
    {:reply, :not_implemented, state}
  end

  def handle_call({%{username: _to_user}, {:send_file, _file_path}}, state) do
    IO.puts("Not implemented")
    {:reply, :not_implemented, state}
  end

  def handle_call({%{channel: _channel}, {:send_file, _file_path}}, state) do
    IO.puts("Not implemented")
    {:reply, :not_implemented, state}
  end

  # Handlers for server messages

  def handle_info({:message, username, message}, state) do
    IO.puts([IO.ANSI.green, username, ": ", IO.ANSI.white, message])
    {:noreply, state}
  end
end