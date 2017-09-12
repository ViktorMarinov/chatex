defmodule ChatexClient.Mixfile do
  use Mix.Project

  def project do
    [app: :chatex_client,
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
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     env: [chatex_username: System.get_env("CHATEX_USERNAME"),
           chatex_keyphrase: System.get_env("CHATEX_KEY"),
           client_node_name: System.get_env("CHATEX_USERNAME"),
           client_location: "localhost",
           server_name: "chatex_server",
           server_location: "SOFM60273496A"],
     mod: {ChatexClient, []}]
  end

  defp deps do
    []
  end

  defp aliases do
    [test: "test --no-start"]
  end
end
