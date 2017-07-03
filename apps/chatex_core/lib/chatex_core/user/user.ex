defmodule ChatexCore.User do
  @enforce_keys [:username]
  defstruct [:username, :socket]

  alias ChatexCore.User

  def new(username, socket \\ nil) do
    %User{username: username, socket: socket}
  end
end