defmodule ChatexServer do
  @doc """
  The application module of the Chatex server.
  Starts the main Supervisor and all of its children in the correct
  order. Uses :rest_for_one strategy.
  """
  use Application

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    ChatexServer.Connectivity.get_env_and_make_accessible()

    children = [
      worker(ChatexServer.User.Registry, [:user_registry]),
      supervisor(ChatexServer.Channel.Supervisor, []),
      worker(ChatexServer.Channel.Registry, [:channel_registry]),
      worker(ChatexServer.Controller, [:chatex_server_controller])
    ]

    Supervisor.start_link(children, [strategy: :rest_for_one,
                          name: ChatexServer.Supervisor])
  end
end
