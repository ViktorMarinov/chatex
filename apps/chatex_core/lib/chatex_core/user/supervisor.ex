defmodule ChatexCore.User.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  def start_user(name) when is_binary(name) do
    Supervisor.start_child(@name, [%ChatexCore.User{name: name}])
  end

  def init(:ok) do
    children = [
      worker(ChatexCore.User, [], [restart: :temporary])
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end