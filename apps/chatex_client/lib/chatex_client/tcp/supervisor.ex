defmodule ChatexClient.TCP.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  def serve(client_socket) do
    {:ok, pid} = Task.Supervisor.start_child(ChatexServer.TCP.TaskSupervisor,
                                             ChatexServer.TCP.Connection, :listen,
                                             [client_socket])
    :ok = :gen_tcp.controlling_process(client_socket, pid)
    {:ok, pid}
  end

  def init(:ok) do
    host = Application.fetch_env!(:chatex_client, :server_host)
    tcp_listen_port = Application.fetch_env!(:chatex_client, :server_tcp_listen_port)

    children = [
      worker(ChatexClient.TCP.Connector, [host, tcp_listen_port])
      worker(Task, [ChatexClient.TCP.Listener, :listen, [port]])
    ]
    supervise(children, strategy: :one_for_one)
  end
end