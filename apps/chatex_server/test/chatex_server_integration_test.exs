defmodule ChatexServerIntegrationTest do
  use ExUnit.Case
  doctest ChatexServer

  @server_name Application.fetch_env!(:chatex_server, :server_name)
  @location Application.fetch_env!(:chatex_server, :server_location)

  setup do
    Application.start(:chatex_server)
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
  end

  describe "" do
    
  end

end
