defmodule ChatexClient.InputReader.InChannel do
  
  alias ChatexClient.Connector
  alias ChatexClient.Command
  alias ChatexClient.InputReader

  def listen(channel) do
    InputReader.read(">")
    |> Command.parse_in_chat()
    |> handle_command(channel)
    |> handle_result(channel)
  end

  defp handle_command({:ok, :exit}, _), do: :exit
  defp handle_command({:ok, :nothing}, _), do: :continue
  defp handle_command(command, channel) do
    case command do
      {:error, {:unknown, command}} -> IO.puts("Unknown command #{command}")
      {:ok, {:message, message}} -> Connector.send_message(channel, message)
      {:ok, :ping} -> Connector.ping |> IO.puts
      {:ok, command} -> Connector.call_command({channel, command})
    end

    :continue
  end

  defp handle_result(:continue, channel), do: listen(channel)
  defp handle_result(:exit, channel), do: IO.puts("Leaving channel #{channel}.")
end