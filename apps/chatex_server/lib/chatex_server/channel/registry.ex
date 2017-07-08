defmodule ChatexServer.Channel.Registry do
  use GenServer

  alias ChatexServer.Channel
  require Logger

  def start_link(name) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  def stop(name) do
    GenServer.stop(name)
  end

  def create(registry, %Channel{} = channel) do
    GenServer.call(registry, {:create, channel})
  end

  def delete(registry, channel_name) do
    GenServer.cast(registry, {:delete, channel_name})
  end

  def get(registry, channel_name) do
    GenServer.call(registry, {:get, channel_name})
  end
  
  @doc """
  Server callbacks
  """

  def init(_) do
    Logger.debug("Initializing Channel.Registry")
    channels = %{}
    refs = %{}
    {:ok, {channels, refs}}
  end

  def handle_call({:create, channel}, _from, {channels, refs}) do
    if Map.has_key?(channels, channel.name) do
      {:reply, {:name_taken, channel.name}, {channels, refs}}
    else
      {:ok, pid} = Channel.Supervisor.start_channel(channel)
      ref = Process.monitor(pid)
      channels = Map.put(channels, channel.name, pid)
      refs = Map.put(refs, ref, channel.name)
      {:reply, {:created, channel.name}, {channels, refs}}
    end
  end

  def handle_call({:get, channel_name}, _from, {channels, _} = state) do
    {:reply, Map.fetch(channels, channel_name), state}
  end

  def handle_cast({:delete, channel_name}, {channels, refs}) do
    channels = Map.delete(channels, channel_name)
    {:noreply, {channels, refs}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {channels, refs}) do
    {channel_name, refs} = Map.pop(refs, ref)
    channels = Map.delete(channels, channel_name)
    {:noreply, {channels, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end