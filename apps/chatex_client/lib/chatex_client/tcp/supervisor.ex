defmodule ChatexClient.TCP.Supervisor do
  use Supervisor

  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  def start_listener(socket) do
    {:ok, pid} = Task.Supervisor.start_child(
      ChatexClient.TCP.TaskSupervisor,
      ChatexClient.TCP.Listener, :listen, [socket]
    )
    Logger.info("Listener started")
    :ok = :gen_tcp.controlling_process(socket, pid)
    {:ok, pid}
  end

  def init(:ok) do
    host = Application.fetch_env!(:chatex_client, :server_host)
    tcp_listen_port = Application.fetch_env!(:chatex_client, :server_tcp_listen_port)

    children = [
      supervisor(Task.Supervisor, [[name: ChatexClient.TCP.TaskSupervisor]]),
      worker(Task, [ChatexClient.TCP.Connector, :connect, [host, tcp_listen_port]])
    ]
    supervise(children, strategy: :rest_for_one)
  end
end