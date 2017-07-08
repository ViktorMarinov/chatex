defmodule ChatexServer.User do
  @moduledoc """
  This module defines a struct for Chatex user.
  Users have a username and key_phrase, which is used
  to authenticate to the server. Both the keys are mendatory.
  """

  @enforce_keys [:username, :key_phrase]
  defstruct [:username, :key_phrase]

  alias ChatexServer.User

  @doc """
  Creates a new user with given username and key_phrase.
  """
  def new(username, key_phrase) do
    %User{
      username: username,
      key_phrase: key_phrase
    }
  end
end