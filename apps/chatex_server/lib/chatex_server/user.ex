defmodule ChatexServer.User do
  @enforce_keys [:username]
  defstruct [:username, :socket]

  alias ChatexServer.User

  def new(username, socket \\ nil) do
    %User{username: username, socket: socket}
  end
end