defmodule ChatexClient.InputReader.InChat do

  alias ChatexClient.Connector
  alias ChatexClient.Command
  alias ChatexClient.InputReader

  @connector_name :connector

  def listen(state) do
    InputReader.read("")
    |> Command.parse_in_chat()
    |> handle_command(state)
    |> handle_result(state)
  end

  defp handle_command({:ok, :exit}, _), do: :exit
  defp handle_command({:ok, :nothing}, _), do: :continue
  defp handle_command(command, state) do
    case command do
      {:error, {:unknown, command}} -> IO.puts("Unknown command #{command}")
      {:ok, :get_history} -> 
        case Connector.call_command(@connector_name, {state, :get_history}) do
          {:error, _} -> IO.puts("Could not get chat history")
          messages -> messages |> Enum.intersperse("\n") |> IO.puts
        end
      {:ok, {:message, message}} -> Connector.send_message(@connector_name, state, message)
      {:ok, command} -> Connector.call_command(@connector_name, {state, command})
    end

    :continue
  end

  defp handle_result(:continue, state), do: listen(state)
  defp handle_result(:exit, %{username: username}), do: IO.puts("Closing chat to user #{username}.")
  defp handle_result(:exit, %{channel: channel}) do 
    IO.puts("Leaving channel #{channel}.")
  end
end