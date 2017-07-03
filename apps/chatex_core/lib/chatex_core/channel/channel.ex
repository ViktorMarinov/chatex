defmodule ChatexCore.Channel do
  alias ChatexCore.Channel

  require Logger

  @enforce_keys [:name]
  defstruct [:name,
            users: %{}]

  @doc """
  Starts a new channel
  """
  def start_link(%Channel{} = channel) do
    Agent.start_link(fn -> channel end)
  end

  def get_users(channel) do
    Agent.get(channel, &(&1.users))
  end

  def add_user(channel, user) do
    Logger.debug("Adding user #{user.username}")
    Agent.update(channel, fn channel ->
      %{channel | users: Map.put(channel.users, user.username, user)}
    end)
  end

  def remove_user(channel, username) do
    Agent.update(channel, fn channel ->
      %{channel | users: Map.delete(channel.users, username)}
    end)
  end
end