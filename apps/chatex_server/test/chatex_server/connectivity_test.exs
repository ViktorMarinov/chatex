defmodule ChatexServer.ConnectivityTest do
  use ExUnit.Case

  alias ChatexServer.Connectivity

  @server_name Application.fetch_env!(:chatex_server, :server_name)
  @location Application.fetch_env!(:chatex_server, :server_location)
  
  setup do
    on_exit fn ->
      Node.stop
    end
  end

  describe "get_env_and_make_accessible" do
    test "gets the node name and location from the env" do
      Connectivity.get_env_and_make_accessible()
      assert Node.alive?
      assert :"#{@server_name}@#{@location}" == Node.self
    end
  end

  describe "make_accessible" do
    test "starts the node when it is not" do
      assert false == Node.alive?
      Connectivity.make_accessible(@server_name, @location)
      assert Node.alive?
    end

    test "returns the name of the node both if started or not" do
      assert {:ok, :"#{@server_name}@#{@location}"} == 
        Connectivity.make_accessible(@server_name, @location)
      assert {:ok, :"#{@server_name}@#{@location}"} == 
        Connectivity.make_accessible("invalid@@name", @location)
    end

    test "returns the {err, reason} if failed to start" do
      assert false == Node.alive?
      assert {:error, _} = 
        Connectivity.make_accessible("invalid@@name", @location)
    end
  end
end