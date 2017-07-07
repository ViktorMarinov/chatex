defmodule ChatexServer.Mixfile do
  use Mix.Project

  def project do
    [app: :chatex_server,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     env: [
       tcp_listen_port: 8000,
       server_name: "chatex_server",
       server_location: "localhost"
    ],
     mod: {ChatexServer, []}]
  end

  defp deps do
    []
  end

  defp aliases do
    [test: "test --no-start"]
  end
end
