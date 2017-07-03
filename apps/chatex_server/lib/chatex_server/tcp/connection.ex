defmodule ChatexServer.TCP.Connection do

  require Logger

  def listen(socket) do
    socket
    |> read()
    |> proccess_command(socket)
    |> write(socket)

    listen(socket)
  end

  defp read(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> data
      {:error, :closed} ->
        Logger.info("Client #{inspect(socket)} disconnected.")
    end
  end

  defp write(data, socket) do
    :gen_tcp.send(socket, data)
  end

  defp proccess_command(command, socket) do
    Logger.debug("Received command #{inspect(command)} from socket #{inspect(socket)}")
    command
  end
end