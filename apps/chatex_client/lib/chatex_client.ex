defmodule ChatexClient do
  use Application

  require Logger

  alias ChatexClient.Connectivity

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Logger.info(Application.get_env(:chatex_server, :chatex_username))

    children = [
      worker(ChatexClient.Connector, [:connector]),
      worker(Connectivity, []),
      # worker(Task, [ChatexClient.InputReader, :start, [username, key_phrase]], restart: :transient)
    ]

    opts = [strategy: :one_for_all, name: ChatexClient.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
