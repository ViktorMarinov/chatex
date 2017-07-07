defmodule ChatexServer.Channel do
  @doc """
  An Agent holding channel's state.
  Users are stored along with their pids.
  """

  alias ChatexServer.Channel

  require Logger

  @enforce_keys [:name, :owner]
  defstruct [:name,
            :owner,
            users: %{}] #{username: pid}

  @doc """
  Starts a new channel
  """
  def start_link(%Channel{} = channel) do
    Agent.start_link(fn -> channel end)
  end

  @doc """
  Gets users of the channel
  """
  def get_users(channel) do
    Agent.get(channel, &(&1.users))
  end

  @doc """
  Returns the owner's username
  """
  def get_owner(channel) do
    Agent.get(channel, &(&1.owner))
  end

  @doc """
  Adds a new user record to the channel
  """
  def add_user(channel, username, pid) do
    Agent.update(channel, fn %Channel{users: users} = channel ->
      %{channel | users: Map.put(users, username, pid)}
    end)
  end

  @doc """
  Removes a user record from the channel
  """
  def remove_user(channel, username) do
    Agent.update(channel, fn %Channel{users: users} = channel ->
      %{channel | users: Map.delete(users, username)}
    end)
  end
end