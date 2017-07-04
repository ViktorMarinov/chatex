defmodule ChatexServer.User.Supervisor do
  use Supervisor

  alias ChatexServer.User

  @name __MODULE__

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, [name: @name])
  end

  def start_user(%User{username: username} = user) when is_binary(username) do
    Supervisor.start_child(@name, [user])
  end

  def init(:ok) do
    children = [
      worker(ChatexServer.User, [], [restart: :temporary])
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end