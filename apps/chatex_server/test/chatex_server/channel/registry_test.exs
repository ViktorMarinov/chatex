defmodule ChatexServer.Channel.RegistryTest do
  use ExUnit.Case
  alias ChatexServer.Channel
  alias ChatexServer.Channel.Registry
  doctest Registry

  describe "start_link" do
    test "Can start and stop the Registry process" do
      {:ok, pid} = Registry.start_link(:test_channel_registry)

      assert Process.alive?(pid)
      Registry.stop(:test_channel_registry)
      assert false == Process.alive?(pid) 
    end
  end

  describe "channel registry" do
    setup do
      {:ok, registry} = Registry.start_link(:test_channel_registry)
      {:ok, registry: registry}
    end

    test "spawns channels", %{registry: registry} do
      assert :error == Registry.get(registry, "BKP")

      Registry.create(registry, %Channel{name: "BKP", owner: "zhivkov"})
      assert {:ok, channel} = Registry.get(registry, "BKP")
      assert "zhivkov" == Channel.get_owner(channel)

      Channel.add_user(channel, "johnie", :pid)
      assert Channel.get_users(channel) |> Map.get("johnie") == :pid
    end

    test "can delete channel", %{registry: registry} do
      Registry.create(registry, %Channel{name: "BKP", owner: "zhivkov"})
      Registry.delete(registry, "BKP")

      :sys.get_state(registry)

      assert Registry.get(registry, "BKP") == :error 
    end

    test "removes channel on exit", %{registry: registry} do
      Registry.create(registry, %Channel{name: "BKP", owner: "zhivkov"})
      {:ok, channel} = Registry.get(registry, "BKP")
      Agent.stop(channel)
      assert Registry.get(registry, "BKP") == :error
    end

    test "removes channel on crash", %{registry: registry} do
      Registry.create(registry, %Channel{name: "BKP", owner: "zhivkov"})
      {:ok, channel} = Registry.get(registry, "BKP")

      ref = Process.monitor(channel)
      Process.exit(channel, :shutdown)
      assert_receive {:DOWN, ^ref, _, _, _}

      assert Registry.get(registry, "BKP") == :error
    end
  end
end