defmodule ChatexClient.CommandTest do
  use ExUnit.Case
  # doctest ChatexClient.Command
  alias ChatexClient.Command

  describe "in main menu" do
    test "can parse open chat to user" do
      assert {:ok, {:open_chat, "pesho"}} == Command.parse "open-chat pesho\r\n"
    end

    test "can parse ping" do
      assert {:ok, :ping} == Command.parse "ping-server\r\n"
    end

    test "can parse channel commands" do
      assert {:ok, {:create_channel, "channel"}} == Command.parse "create-channel channel"
      assert {:ok, {:delete_channel, "channel"}} == Command.parse "delete-channel channel"
      assert {:ok, {:join_channel, "channel"}} == Command.parse "join-channel channel"
    end

    test "returns error on unknown command" do
      assert {:error, {:unknown, "unknown command"}} == Command.parse "unknown command"
    end
  end

  describe "in chat" do
    test "can parse exit command" do
      assert {:ok, :exit} == Command.parse_in_chat ":exit\r\n"
    end

    test "does not represent whitespaces as a message" do
      assert {:ok, :nothing} == Command.parse_in_chat "     \t"
    end

    test "can parse get history command" do
      assert {:ok, :get_history} == Command.parse_in_chat ":get-history\r\n"
    end

    test "can parse send file command" do
      assert {:ok, {:send_file, "~/dickbut.gif"}} == 
        Command.parse_in_chat ":send-file ~/dickbut.gif"
    end

    test "represents line starting with colon as command" do
      assert {:error, {:unknown, ":message"}} == Command.parse ":message"
    end

    test "represends everything not starting with colon as message" do
      assert {:ok, {:message, "what's up"}} == 
        ChatexClient.Command.parse_in_chat "what's up\r\n"
      assert {:ok, {:message, "send-file ~/dickbut.gif"}} ==
        ChatexClient.Command.parse_in_chat "send-file ~/dickbut.gif\r\n"
    end
  end
end
