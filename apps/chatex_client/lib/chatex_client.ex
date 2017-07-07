defmodule ChatexClient do
  use Application

  require Logger

  alias ChatexClient.Connectivity
  alias ChatexClient.InputReader

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {username, key_phrase} = InputReader.get_credentials()

    Connectivity.get_env_and_connect(username)
    Logger.info("Connected to server node.")

    children = [
      worker(ChatexClient.Connector, [:connector]),
      # worker(Task, [ChatexClient.InputReader, :start, [username, key_phrase]], restart: :transient)
    ]

    opts = [strategy: :one_for_one, name: ChatexClient.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
