defmodule ChatexServerIntegrationTest do
  use ExUnit.Case
  doctest ChatexServer

  @server_name Application.fetch_env!(:chatex_server, :server_name)
  @location Application.fetch_env!(:chatex_server, :server_location)

  setup do
    Application.start(:chatex_server)
    Application.ensure_all_started(:chatex_server)
    :ok
  end

  describe "start-up" do
    test "node is alive with the proper name" do
      assert Node.alive?
      assert :"#{@server_name}@#{@location}" == Node.self
    end

    test "controller and registries are started" do
      assert :global.whereis_name(:chatex_server_controller) |> Process.alive?
      assert Process.whereis(:user_registry) |> Process.alive?
      assert Process.whereis(:channel_registry) |> Process.alive?
    end

    test "can ping controller" do
      assert {:pong, pid} = call(:ping)
      assert is_pid(pid)
    end
  end

  describe "registration and connectivity" do
    test "can register user and connect" do
      assert {:registered, "pesho"} == call({:register, "pesho", "pass"})
      assert :ok == call({:connect, "pesho", "pass"})
    end

    test "cannot connect if not registered" do
      assert {:error, :unregistered} == call({:connect, "gencho", "pass"})
    end

    test "cannot register if username is taken" do
      assert {:registered, "gosho"} == call({:register, "gosho", "pass"})
      assert {:error, :username_taken} == call({:register, "gosho", "pass"})
    end

    test "cannot connect with wrong keyphrase" do
      assert {:registered, "pencho"} == call({:register, "pencho", "pass"})
      assert {:error, :invalid} == call({:connect, "pencho", "wrong"})
    end

    test "check user status" do
      assert {:error, :user_not_found} = call({:user_status, "johny"})
      call({:register, "johny", "pass"})
      assert {:ok, :offline} = call({:user_status, "johny"})
      call({:connect, "johny", "pass"})
      assert {:ok, :online} = call({:user_status, "johny"})
    end
  end

  describe "sending messages" do
    test "cannot send message if not connected" do
      assert {:error, :not_connected} == call({:send_private_message, "pesho", "hey"})
    end

    test "send message from one user to another" do
      call({:register, "john", "pass"})
      call({:register, "doe", "pass"})
      spawn fn ->
        call({:connect, "john", "pass"})
        receive do
          {:message, "doe", "who are you?"} ->
            call({:send_private_message, "doe", "I don't know"})
        after
          1000 -> flunk "User john did not receive the message"
        end
      end

      call({:connect, "doe", "pass"})
      call({:send_private_message, "john", "who are you?"})
      receive do
        {:message, "john", "I don't know"} -> :ok
      after
        1000 -> flunk "User doe did not receive the message"
      end
    end
  end

  describe "channel operations" do
    test "create channel" do
      call({:register, "charlie", "pass"})
      call({:connect, "charlie", "pass"})
      assert {:created, "chocolate"} = call({:create_channel, "chocolate"})
    end

    test "delete channel" do
      call({:register, "charles", "pass"})
      call({:connect, "charles", "pass"})
      assert {:created, "chocolate2"} = call({:create_channel, "chocolate2"})
      assert :ok = call({:delete_channel, "chocolate2"})
    end

    test "join channel" do
      call({:register, "bob", "pass"})
      call({:connect, "bob", "pass"})
      call({:create_channel, "bobs-channel"})
      assert :ok = call({:join_channel, "bobs-channel"})
      assert call({:get_channel_users, "bobs-channel"}) |> Enum.member?("bob")
    end

    test "send message to channel" do
      call({:register, "petko", "pass"})
      call({:connect, "petko", "pass"})
      call({:create_channel, "bobby"})
      :ok = call({:join_channel, "bobby"})
      spawn fn ->
        call({:register, "kiro", "pass"})
        call({:connect, "kiro", "pass"})
        call({:join_channel, "bobby"})
        receive do
          {:channel_message, "bobby", "petko", "How you doing, guys?"} ->
            IO.puts("kiro received the message")
            call({:send_to_channel, "bobby", "Good, you?"})
        after
          4000 -> flunk "User kiro did not receive the channel message"
        end
      end
      
      ensure_user_has_joined("bobby", "petko")
      ensure_user_has_joined("bobby", "kiro")
      call({:send_to_channel, "bobby", "How you doing, guys?"})
      receive do
        {:channel_message, "bobby", "kiro", "Good, you?"} -> :ok
      after
        4000 -> flunk "User petko did not receive the channel message"
      end
    end
  end

  defp call(args) do
    GenServer.call({:global, :chatex_server_controller}, args)
  end

  defp ensure_user_has_joined(channel, user, timeout \\ 5000) do
    unless call({:get_channel_users, channel}) |> Enum.member?(user) do
      Process.sleep(400)
      ensure_user_has_joined(channel, user, timeout - 400)
    end
  end
end
