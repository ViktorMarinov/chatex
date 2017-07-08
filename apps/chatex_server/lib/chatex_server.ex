defmodule ChatexServer do
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
