defmodule ChatexServer.Connectivity do

  require Logger

  def get_env_and_make_accessible do
    name = Application.fetch_env!(:chatex_server, :server_name)
    location = Application.fetch_env!(:chatex_server, :server_location)

    make_accessible(name, location)
  end
  
  def make_accessible(name, location) do
    if Node.alive? do
      {:ok, Node.self()}
    else
      case Node.start(:"#{name}@#{location}") do
        {:ok, pid} -> {:ok, Node.self()}
        err -> err
      end
    end
  end
end