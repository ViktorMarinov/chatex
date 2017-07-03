defmodule ChatexServer.TCP.Listener do
  @moduledoc """
  TODO: add module doc
  """

  require Logger

  def listen(port) do
    opts = [:binary, packet: :line, active: false, reuseaddr: true]
    {:ok, socket} = :gen_tcp.listen(port, opts)
    Logger.info("Chatex Server started on port #{port}")
    accept(socket)
  end

  defp accept(server_socket) do
    {:ok, client_socket} = :gen_tcp.accept(server_socket)
    {:ok, _pid} = ChatexServer.TCP.Supervisor.serve(client_socket)
    accept(server_socket)
  end
end