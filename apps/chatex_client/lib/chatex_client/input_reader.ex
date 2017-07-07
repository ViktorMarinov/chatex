defmodule ChatexClient.InputReader do

  alias ChatexClient.Connector
  alias ChatexClient.Command
  alias ChatexClient.InputReader.InChat

  @connector_name :connector

  def get_credentials do
    name = Application.get_env(:chatex_client, :chatex_username) ||
      read("Enter username: ")
    key_phrase = Application.get_env(:chatex_client, :chatex_keyphrase) ||
      read("Enter keyphrase: ")
    {name, key_phrase}
  end

  def start(username, key_phrase) do
    Node.list |> IO.inspect
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
  defp handle_connect({:error, :unregistered}, {username, key_phrase}) do
    IO.puts("Unregistered #{username}")
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
      {:ok, {:open_chat, to_user}} ->
        IO.puts("Entering chat with #{to_user}")
        InChat.listen(%{username: to_user})
      {:ok, {:join_channel, channel_name}} -> 
        IO.puts("Joining channel #{channel_name}")
        InChat.listen(%{channel: channel_name})
      {:ok, command} -> Connector.call_command(@connector_name, command)
    end

    listen()
  end
end