defmodule ChatexClient.ConnectorTest do
  use ExUnit.Case, async: true
  doctest ChatexClient.Connector

  alias ChatexClient.Connector

  defmodule TestServer do
    use GenServer

    @name Application.get_env(:chatex_client, :server_name, :test_server)

    def start_link do
      GenServer.start_link(__MODULE__, nil, name: {:global, @name})
    end

    def handle_call({:register, :valid, _key_phrase}, _, state) do
      {:reply, {:registered, :valid}, state}
    end
    def handle_call({:register, :invalid, _key_phrase}, _, state) do
      {:reply, {:error, :username_taken}, state}
    end

    def handle_call({:connect, username, key_phrase}, _, state) do
      result = 
        case {username, key_phrase} do
          {:valid, :valid} -> :ok
          {:unregistered, _} -> {:error, :unregistered}
          {:valid, :invalid} -> {:error, :invalid}
        end
      {:reply, result, state}
    end

    def handle_call(:ping, _, state), do: {:reply, {:pong, self()}, state}

    def handle_call({:send_private_message, to_user, _message}, _, state) do
      case to_user do
        :valid_user -> {:reply, :ok, state}
        :invalid_user -> {:reply, {:error, :user_not_found}, state}
      end
    end

    def handle_call({:send_to_channel, channel, _message}, _, state) do
      case channel do
        :valid_channel -> {:reply, :ok, state}
        :invalid_channel -> {:reply, {:error, :channel_not_found}, state}
      end
    end
  end
  
  setup %{test: test}do
    {:ok, _} = TestServer.start_link
    # Naming connector with the name of the test
    {:ok, _} = Connector.start_link(test)

    :ok
  end


  describe "start_link" do
    test "starts the connector process", %{test: connector} do
      assert Process.whereis(connector) |> Process.alive?
    end
  end

  describe "register" do
    test "returns :ok on success", %{test: connector} do
      assert :ok == Connector.register(connector, :valid, "pass")
    end

    test "returns {:error, :username_taken} when username is taken", %{test: connector} do
      assert {:error, :username_taken} == Connector.register(connector, :invalid, "pass")
    end
  end

  describe "connect" do
    test "returns error if already connected", %{test: connector} do
      :ok = Connector.connect(connector, :valid, :valid)
      assert {:error, :already_connected} == Connector.connect(connector, :valid, :valid)
    end

    test "adds the username to the state on success", %{test: connector} do
      :ok = Connector.connect(connector, :valid, :valid)
      state = Process.whereis(connector) |> :sys.get_state
      assert %{username: :valid} = state
    end
  end

  describe "send message" do
    test "can send to user", %{test: connector} do
      assert :ok == Connector.send_message(connector, %{username: :valid_user}, "what's up")
    end

    test "can send to channel", %{test: connector} do
      assert :ok == Connector.send_message(connector,  %{channel: :valid_channel}, "what's up")
    end
  end
end