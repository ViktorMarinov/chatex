defmodule ChatexCore.Channel.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  def start_channel(name) when is_binary(name) do
    Supervisor.start_child(@name, [%ChatexCore.Channel{name: name}])
  end

  def init(:ok) do
    children = [
      worker(ChatexCore.Channel, [], [restart: :temporary])
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end