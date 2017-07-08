defmodule ChatexClient.InputReader do

  alias ChatexClient.Connector
  alias ChatexClient.Command
  alias ChatexClient.InputReader.InChat

  @connector_name :connector

  # def get_credentials do
  #   name = Application.get_env(:chatex_client, :chatex_username) ||
  #     IO.gets("Enter username: ")
  #   key_phrase = Application.get_env(:chatex_client, :chatex_keyphrase) ||
  #     IO.gets("Enter keyphrase: ")
  #   {name, key_phrase}
  # end

  def start(username, key_phrase) do
    read("Press enter to continue")

    Connector.connect(@connector_name, username, key_phrase)
    |> handle_connect({username, key_phrase})

    listen()
  end

  def read(device \\ :stdio, message) do
    IO.gets(device, message) |> String.trim
  end

  defp handle_connect(:ok, {username, _}) do 
    IO.puts(["Successfuly connected with username #{username}"])
  end
  defp handle_connect({:error, :invalid}, _) do
    IO.puts([IO.ANSI.red, "Invalid username or password"])
        read_credentials_and_start()
  end
  defp handle_connect({:error, :already_connected}, {username, key_phrase}) do
    
  end
  defp handle_connect({:error, :unregistered}, {username, key_phrase}) do
    IO.puts("User #{username} is not registered.")
    case Connector.register(@connector_name, username, key_phrase) do
      :ok -> start(username, key_phrase)
      {:error, :username_taken} -> read_credentials_and_start()
    end
  end

  defp read_credentials_and_start do
    username = read("Enter username: ")
    keyphrase = read("Enter keyphrase: ")
    start(username, keyphrase)
  end

  defp listen() do
    read("")
    |> Command.parse()
    |> handle_command()
  end

  defp handle_command({:ok, :exit}), do: IO.puts("Stopping Chatex") #TODO: exit
  defp handle_command(command) do
    case command do
      {:error, {:unknown, command}} -> IO.puts("Unknown command #{command}")
      {:ok, {:open_chat, username}} ->
        open_chat_to_user(username)
      {:ok, {:join_channel, channel_name}} ->
        join_channel(channel_name)
      {:ok, command} -> Connector.call_command(@connector_name, command)
    end

    listen()
  end

  defp open_chat_to_user(username) do
    with {:ok, :online} <- Connector.call_command(@connector_name, {:user_status, username}) do
      IO.puts("Entering chat with user #{username}")
      InChat.listen(%{username: username})
    else
      {:ok, :offline} -> IO.puts("User is not online")
      {:error, :user_not_found} -> IO.puts("There is no user with username #{username}")
    end
  end

  defp join_channel(channel_name) do
    with :ok <- Connector.call_command(@connector_name, {:join_channel, channel_name}) do
      IO.puts("Joining channel #{channel_name}")
      InChat.listen(%{channel: channel_name})
    else
      {:error, :channel_not_found} -> IO.puts("There is no channel with name #{channel_name}")
    end

  end
end