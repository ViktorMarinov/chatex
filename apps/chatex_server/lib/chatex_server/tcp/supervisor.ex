defmodule ChatexServer.TCP.Supervisor do
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
    port = Application.fetch_env!(:chatex_server, :tcp_listen_port)
    children = [
      supervisor(Task.Supervisor, [[name: ChatexServer.TCP.TaskSupervisor]]),
      worker(Task, [ChatexServer.TCP.Listener, :listen, [port]])
    ]
    supervise(children, strategy: :one_for_one)
  end
end