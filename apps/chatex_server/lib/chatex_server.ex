defmodule ChatexServer do
  use Application

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    name = Application.fetch_env!(:chatex_server, :server_name)
    location = Application.fetch_env!(:chatex_server, :server_location)

    node_name = 
      case make_accessible(name, location) do
        {:ok, pid} when is_pid(pid) -> "#{name}@#{location}"
        {:ok, name} when is_atom(name) -> name
      end

    Logger.info("Chatex is accessible with name #{node_name}")

    children = [
      supervisor(ChatexServer.Channel.Supervisor, []),
      worker(ChatexServer.Channel.Registry, [ChatexServer.Channel.Registry]),
      worker(ChatexServer.User.Registry, [:user_registry]),
      worker(ChatexServer.Controller, [:chatex_server_controller])
    ]

    Supervisor.start_link(children, [strategy: :one_for_one,
                          name: ChatexServer.Supervisor])
  end

  defp make_accessible(name, location) do
    if Node.alive? do
      {:ok, Node.self()}
    else
      Node.start(:"#{name}@#{location}")
    end
  end
end
