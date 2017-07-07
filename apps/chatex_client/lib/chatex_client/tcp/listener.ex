defmodule ChatexClient.TCP.Listener do

  require Logger

  def listen(server_socket) do
    case :gen_tcp.recv(server_socket, 0) do
      {:ok, message} -> 
        IO.puts(["Received message: ", message])
        listen(server_socket)
      {:error, :closed} -> 
        IO.puts([IO.ANSI.red, "Server was shut down.", IO.ANSI.normal])
        Process.exit(self(), :kill)
      other ->
        Logger.error(other)
    end
  end
end