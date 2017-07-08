defmodule Chatex.Mixfile do
  use Mix.Project

  def project do
    [apps_path: "apps",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  defp deps do
    []
  end

  defp aliases do
    [test: "test --no-start"]
  end
end
