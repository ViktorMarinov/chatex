defmodule ChatexCore do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(ChatexCore.User.Supervisor, []),
      worker(ChatexCore.Channel.Supervisor, [])
      #TODO: add registry and controller
    ]

    Supervisor.start_link(children,
                          strategy: :rest_for_one, 
                          name: ChatexCore.Supervisor)
  end
end
