defmodule ChatexClient do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    host = Application.fetch_env!(:chatex_client, :server_host)
    tcp_listen_port = Application.fetch_env!(:chatex_client, :server_tcp_listen_port)

    children = [
      worker(ChatexClient.Connector, [host, tcp_listen_port])
    ]

    opts = [strategy: :one_for_one, name: ChatexClient.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
