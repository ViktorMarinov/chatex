defmodule ChatexClient.InputReader.InChat do

  alias ChatexClient.Connector
  alias ChatexClient.Command
  alias ChatexClient.InputReader

  def listen(to_user) do
    InputReader.read(">")
    |> Command.parse_in_chat()
    |> handle_command(to_user)
    |> handle_result(to_user)
  end

  defp handle_command({:ok, :exit}, _), do: :exit
  defp handle_command({:ok, :nothing}, _), do: :continue
  defp handle_command(command, to_user) do
    case command do
      {:error, {:unknown, command}} -> IO.puts("Unknown command #{command}")
      {:ok, {:message, message}} -> Connector.send_message(to_user, message)
      {:ok, command} -> Connector.call_command({to_user, command})
    end

    :continue
  end

  defp handle_result(:continue, to_user), do: listen(to_user)
  defp handle_result(:exit, to_user), do: IO.puts("Closing chat to user #{to_user}.")
end