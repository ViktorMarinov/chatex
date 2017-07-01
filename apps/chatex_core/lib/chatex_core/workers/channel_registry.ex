defmodule ChatexCore.ChannelRegistry do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, [])
  end

  

  def init(_) do
    {:ok, []}
  end
end