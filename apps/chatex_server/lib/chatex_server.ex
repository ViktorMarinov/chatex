defmodule ChatexServer do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(ChatexServer.TCP.Supervisor, []),
      supervisor(ChatexServer.User.Supervisor, []),
      supervisor(ChatexServer.Channel.Supervisor, []),
      worker(ChatexServer.Channel.Registry, [ChatexServer.Channel.Registry]),
      worker(ChatexServer.User.Registry, [ChatexServer.User.Registry])
    ]

    Supervisor.start_link(children, [strategy: :one_for_one,
                          name: ChatexServer.Supervisor])
  end
end
