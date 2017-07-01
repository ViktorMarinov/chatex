defmodule ChatexCore do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(ChatexCore.UserRegistry, [:user_registry]),
      worker(ChatexCore.ChannelRegistry, [])
      # supervisor(ChatexCore.Repo, []),
      # supervisor(ChatexCore.User.Supervisor, [])
      # supervisor(ChatexCore.Channel.Supervisor, [])
    ]

    Supervisor.start_link(children,
                          strategy: :rest_for_one, 
                          name: ChatexCore.Supervisor)
  end

  def hello do
    :world
  end
end
