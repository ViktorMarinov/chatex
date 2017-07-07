defmodule ChatexClient.Connectivity do

  require Logger

  def get_env_and_connect(username) do
    client_location = Application.get_env(:chatex_client, :client_location)
    server_name = Application.get_env(:chatex_client, :server_name)
    server_location = Application.get_env(:chatex_client, :server_location)

    make_alive(username, client_location)
    connect_to_server_node(server_name, server_location)
  end

  def make_alive(name, location) do
    unless Node.alive? do
      node_name = :"#{name}@#{location}"
      Logger.info("Starting node with name #{node_name}")
      Node.start(node_name)
    end
  end

  def connect_to_server_node(name, location) do
    Logger.info("Connecting to #{name}@#{location}...")
    case Node.connect(:"#{name}@#{location}") do
      true ->
        IO.puts([IO.ANSI.green, "Connecting to server was successful"])
      false ->
        IO.puts([IO.ANSI.red, "Could not connect to server"])
        Process.sleep(3000)
        IO.puts([IO.ANSI.red, "Trying again..."])
        connect_to_server_node(name, location)
    end
  end
end