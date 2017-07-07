defmodule ChatexClient.Connector do
  use GenServer

  require Logger

  @name __MODULE__
  @server_name :chatex_server_controller

  def start_link do
    Logger.debug("Starting #{@name}")
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def register(username, key_phrase) do
    GenServer.call(@name, {:register, username, key_phrase})
  end

  def connect(username, key_phrase) do
    GenServer.call(@name, {:connect, username, key_phrase})
  end

  def ping() do
    GenServer.call(@name, :ping)
  end

  def send_message(to_user, message) do
    GenServer.cast(@name, {:send_private_message, to_user, message})
  end

  def call_command(command) do
    GenServer.call(@name, command)
  end

  # Server callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:send_private_message, _to_user, _message} = call_info, user) do
    GenServer.call({:global, @server_name}, call_info)
    {:noreply, user}
  end

  def handle_call({:register, username, key_phrase}, _, _) do
    case GenServer.call({:global, @server_name}, {:register, username, key_phrase}) do
      :ok -> {:reply, :ok, %{}}
      {:error, _} = err -> {:reply, err, %{}}
    end
  end

  def handle_call({:connect, username, key_phrase}, _, %{}) do
    case GenServer.call({:global, @server_name}, {:connect, username, key_phrase}) do
      # Removed key_phrase from state
      :ok -> {:reply, :ok, %{username: username}}
      {:error, _} = err -> {:reply, err, %{}}
    end
  end
  def handle_call({:connect, _, _}, _, state) do
    {:reply, {:error, :already_connected}, state}
  end

  def handle_call(:ping, _, user) do
    {:reply, GenServer.call({:global, @server_name}, :ping), user}
  end

  def handle_call({:create_channel, name}, _, state) do
    IO.puts("Not implemented")
    {:reply, :ok, state}
  end

  def handle_call({:delete_channel, name}, _, state) do
    IO.puts("Not implemented")
    {:reply, :ok, state}
  end

  # Handlers for server messages

  def handle_info({:message, username, message}, state) do
    IO.puts([IO.ANSI.green, username, ": ", IO.ANSI.white, message])
    {:noreply, state}
  end
end