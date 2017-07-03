defmodule ChatexServer do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(ChatexServer.TCP.Supervisor, [])
    ]

    Supervisor.start_link(children, [strategy: :one_for_one,
                          name: ChatexServer.Supervisor])
  end
end
