defmodule ChatexClient.TCP.Listener do
  def listen(server_socket) do
    case :gen_tcp.recv(server_socket, 0) do
      {:registered, user} -> IO.puts("Registered successfuly with username #{user.username}")
      {:message, message} -> IO.puts("Received message: #{message}")
    end

    listen(server_socket)
  end
end