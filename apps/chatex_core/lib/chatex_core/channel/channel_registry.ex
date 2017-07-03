defmodule ChatexCore.ChannelRegistry do
  use GenServer

  alias ChatexCore.Channel
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

  def handle_call({:create, channel}, channels) do
    if Map.has_key?(channels, channel.name) do
      
    else 

    end
  end
end