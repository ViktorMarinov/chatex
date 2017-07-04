defmodule ChatexClient do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(ChatexClient.TCP.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: ChatexClient.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
