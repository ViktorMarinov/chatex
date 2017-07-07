defmodule ChatexClient.Command do
  @doc """
  Parses the given `line` into a command.

  ## Examples

      iex> ChatexClient.Command.parse "send-private-message john what's up\r\n"
      {:ok, {:send_private_message, "john", "what's up"}}

      iex> ChatexClient.Command.parse "ping-server\r\n"
      {:ok, :ping}

  """
  def parse(line) do
    case String.split(line) do
      ["exit"] -> {:ok, :exit}
      ["open-chat", to_user] -> {:ok, {:open_chat, to_user}}
      ["ping-server"] -> {:ok, :ping}
      ["create-channel", name] -> {:ok, {:create_channel, name}}
      ["delete-channel", name] -> {:ok, {:delete_channel, name}}
      ["join-channel", name] -> {:ok, {:join_channel, name}}
      _ -> {:error, {:unknown, line}}
    end
  end

  def parse_in_chat(line) do
    if String.starts_with?(line, ":") do
      parse_in_chat_command(line)
    else
      parse_message(line)
    end
  end

  defp parse_in_chat_command(line) do
    case String.split(line) do
      [":exit"] -> {:ok, :exit}
      [] -> {:ok, :nothing}
      [":get-history"] -> {:ok, :get_history}
      [":send-file", file_path] -> {:ok, {:send_file, file_path}}
      _ -> {:error, {:unknown, line}}
    end
  end

  defp parse_message(line) do
    case String.trim(line) do
      "" -> {:ok, :nothing}
      message -> {:ok, {:message, message}}
    end
  end

end