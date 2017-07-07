defmodule ChatexServer.TCP.Connection do
  require Logger

  def accept_user(socket) do
    Logger.info("New connection #{inspect(socket)}")
    user = ask_register(socket)
    listen(socket, user)
  end

  defp ask_register(socket) do
    write("Enter username ", socket)
    case read(socket) |> register_user do
      {:registered, user} ->
        write("Registered successfully.", socket)
        user
      {:username_taken, username} ->
         write("Username #{username} is already taken.", socket)
         ask_register(socket)
    end
  end

  defp register_user(username) do
    #TODO: validate and check username taken
    # register user
    # add mapping socket/user
    {:registered, %ChatexServer.User{username: username}}
  end

  def listen(socket, user) do
    socket
    |> read()
    |> proccess_command(socket, user)
    |> write(socket)

    listen(socket, user)
  end

  defp read(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> 
        String.trim(data)
      {:error, :closed} ->
        Logger.info("Client #{inspect(socket)} disconnected.")
        #TODO: delete user from registry
        Process.exit(self(), :normal)
    end
  end

  defp write(data, socket) do
    :gen_tcp.send(socket, data <> "\r\n")
  end

  defp proccess_command(command, socket, user) do
    Logger.debug("Received command #{inspect(command)} from #{inspect(socket)} user #{inspect(user)}")
    command
  end
end