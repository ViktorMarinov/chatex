defmodule Chatex.Mixfile do
  use Mix.Project

  def project do
    [apps_path: "apps",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
     aliases: aliases(),
     deps: deps()]
  end

  defp deps do
    [{:excoveralls, "~> 0.7", only: :test}]
  end

  defp aliases do
    [test: "test --no-start"]
  end
end
