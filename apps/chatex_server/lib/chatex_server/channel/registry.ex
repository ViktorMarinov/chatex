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

  def create_channel(registry, %Channel{} = channel) do
    GenServer.call(registry, {:create, channel})
  end

  def delete_channel(registry, %Channel{} = channel) do
    GenServer.cast(registry, {:delete, channel})
  end

  def get_channel(registry, channel_name) do
    GenServer.call(registry, {:get, channel_name})
  end
  
  @doc """
  Server callbacks
  """

  def init(_) do
    Logger.debug("Initializing ChannelRegistry")
    {:ok, %{}}
  end

  def handle_call({:create, channel}, _from, channels) do
    if Map.has_key?(channels, channel.name) do
      {:reply, {:name_taken, channel.name}, channels}
    else 
      Logger.info("Creating channel #{channel.name}")
      {:reply, {:created, channel}, Map.put(channels, channel.name, channel)}
    end
  end

  def handle_call({:get, channel_name}, _from, channels) do
    {:reply, Map.get(channels, channel_name), channels}
  end

  def handle_cast({:delete, channel_name}, channels) do
    {:noreply, Map.delete(channels, channel_name)}
  end
end