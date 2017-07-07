defmodule ChatexServer.User do
  @enforce_keys [:username]
  defstruct [:username, :key_phrase]

  alias ChatexServer.User

  def new(username, key_phrase) do
    %User{
      username: username,
      key_phrase: key_phrase
    }
  end
end