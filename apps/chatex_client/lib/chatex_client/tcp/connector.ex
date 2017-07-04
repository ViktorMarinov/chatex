defmodule ChatexClient.TCP.Connector do
  require Logger
  use GenServer

  def start_link(server_host, server_port) do
    GenServer.start_link(__MODULE__, {server_host, server_port})
  end

  @doc """
  Server callbacks
  """

  def init({server_host, server_port}) do
    IO.puts("Connecting to server #{server_host}@#{server_port}")
    user_info = input_user()
    Logger.info(inspect(user_info))
    {:ok, user_info}
  end

  defp input_user() do
    [username: "Enter username: ",
     first_name: "Enter first name: ",
     last_name: "Enter last name: ",
     age: {"Enter age: ", &Integer.parse/1}]
    |> Enum.map(fn {key, value} -> 
         {key, read(value)}
       end)
    |> Enum.into(%{})
  end

  defp read(message) when is_binary(message) do 
    IO.gets(message) #TODO: add env var for input device
    |> String.trim
  end
  defp read({message, map_function}) do
    {res, _} = map_function.(read(message))
    res
  end

  defp validate({:username, username}), do: username
end