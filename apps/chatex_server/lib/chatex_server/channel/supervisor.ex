defmodule ChatexServer.Channel.Supervisor do
  @doc """
  This is a supervisor that manages the channel agent processes.
  Uses :simple_one_for_one strategy for dynamically starting new
  processes. Channel agents should be started only by this supervisor.
  """
  use Supervisor

  alias ChatexServer.Channel

  @name __MODULE__

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, [name: @name])
  end

  @doc """
  Starts a new channel proccess. 
  Accepts %Channel{} struct, which is the state of the Channel agent
  """
  def start_channel(%Channel{name: name} = channel) when is_binary(name) do
    Supervisor.start_child(@name, [channel])
  end

  def init(:ok) do
    children = [
      worker(ChatexServer.Channel, [], [restart: :temporary])
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end