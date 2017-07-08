defmodule ChatexClient.Connector do
  use GenServer

  require Logger

  @server_controller_name Application.get_env(
    :chatex_client, :server_controller_name, :chatex_server_controller)

  def start_link(name) do
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
    call_server_controller({:send_private_message, to_user, message})
    {:noreply, user}
  end
  def handle_cast({:message, %{channel: channel}, message}, user) do
    call_server_controller({:send_to_channel, channel, message})
    {:noreply, user}
  end

  def handle_call({:register, username, key_phrase}, _, _) do
    case call_server_controller({:register, username, key_phrase}) do
      {:registered, _} -> {:reply, :ok, %{}}
      {:error, _} = err -> {:reply, err, %{}}
    end
  end

  def handle_call({:connect, username, key_phrase}, _, %{}) do
    case call_server_controller({:connect, username, key_phrase}) do
      :ok -> {:reply, :ok, %{username: username}}
      {:error, _} = err -> {:reply, err, %{}}
    end
  end

  def handle_call({%{username: _}, :get_history}, _, state) do
    IO.puts("Not available for private chats")
    {:reply, :ok, state}
  end

  def handle_call({%{channel: channel_name}, :get_history}, _, state) do
    {:reply, call_server_controller({:get_history, channel_name}), state}
  end

  def handle_call(command, _, state) do
    {:reply, call_server_controller(command), state}
  end

  defp call_server_controller(args) do
    GenServer.call({:global, @server_controller_name}, args)
  end

  # Handlers for server messages

  def handle_info({:message, username, message}, state) do
    IO.puts([IO.ANSI.green, username, ": ", IO.ANSI.white, message])
    {:noreply, state}
  end

  def handle_info({:channel_message, channel_name, from_user, message}, state) do
    IO.puts([IO.ANSI.bright, from_user, "(#{channel_name}): ", IO.ANSI.white, message])
    {:noreply, state}
  end
end