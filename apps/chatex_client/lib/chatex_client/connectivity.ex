defmodule ChatexClient.Connectivity do

  use GenServer

  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    state = get_env()
    connect_to_server_node(state.server_name, state.server_location)
    start_input_reader(state.username)
    {:ok, state}
  end

  def handle_info({:nodedown, _}, %{server_name: name, server_location: location} = state) do
    connect_to_server_node(name, location)
    start_input_reader(state.username)
    {:noreply, state}
  end

  defp get_env do
    username = get_username()
    client_location = Application.get_env(:chatex_client, :client_location)
    server_name = Application.get_env(:chatex_client, :server_name)
    server_location = Application.get_env(:chatex_client, :server_location)

    {username, client_location} = make_alive(username, client_location)
    state = %{
      username: username,
      client_location: client_location,
      server_name: server_name,
      server_location: server_location
    }
    IO.inspect(state)
  end

  defp make_alive(name, location) do
    unless Node.alive? do
      node_name = :"#{name}@#{location}"
      Logger.info("Starting node with name #{node_name}")
      Node.start(node_name)
      {name, location}
    else
      [name, location] = to_string(Node.self()) |> String.split("@")
      {name, location}
    end
  end

  defp connect_to_server_node(name, location) do
    IO.puts("Connecting to #{name}@#{location}...")
    node_name = :"#{name}@#{location}"
    case Node.connect(node_name) do
      true ->
        IO.puts([IO.ANSI.green, "Connecting to server was successful", IO.ANSI.white])
        Node.monitor(node_name, true)
      false ->
        IO.puts([IO.ANSI.red, "Could not connect to server. Trying again..." , IO.ANSI.white])
        Process.sleep(2000)
        connect_to_server_node(name, location)
    end
  end

  defp start_input_reader(username) do
    Task.start(ChatexClient.InputReader, :start, [username, get_keyphrase()])
  end

  def get_keyphrase do
    Application.get_env(:chatex_client, :chatex_keyphrase) ||
      IO.gets("Enter keyphrase: ")
  end

  def get_username do
    Application.get_env(:chatex_client, :chatex_username) ||
      IO.gets("Enter username: ")
  end
end