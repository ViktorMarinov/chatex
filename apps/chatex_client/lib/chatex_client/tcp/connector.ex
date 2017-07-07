defmodule ChatexClient.TCP.Connector do
  require Logger
  use GenServer

  def connect(server_host, server_port) do
    Logger.info("Connecting to server #{server_host}@#{server_port}")
    socket = connect_to_server(server_host, server_port)
    ChatexClient.TCP.Supervisor.start_listener(socket)
    loop(socket)
  end

  defp loop(socket) do
    read_input()
    |> write(socket)

    loop(socket)
  end

  defp read_input() do
    IO.gets(">")
  end

  defp write(data, socket) do
    case :gen_tcp.send(socket, data) do
      :ok -> :ok
      _err -> 
        #TODO: reconnect?
        Logger.error("Could not send message to server")
    end
  end

  defp connect_to_server(server_host, server_port) do
    opts = [:binary, packet: :line, active: false]
    case :gen_tcp.connect(server_host, server_port, opts) do
      {:ok, socket} -> 
        Logger.info(IO.ANSI.green <> "Connected")
        socket
      error ->
        Logger.error("Could not connect to #{server_host}@#{server_port}. Reason:  #{inspect(error)}")
        Logger.info("Retrying connection...")
        Process.sleep(1000)
        connect_to_server(server_host, server_port)
    end
  end
end