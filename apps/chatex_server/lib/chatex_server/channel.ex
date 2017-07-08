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
            users: %{},
            messages: []] #{username: pid}

  @doc """
  Starts a new channel
  """
  def start_link(%Channel{} = channel) do
    Agent.start_link(fn -> channel end)
  end

  def get_name(channel) do
    Agent.get(channel, &(&1.name))
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

  def get_messages(channel) do
    Agent.get(channel, &Enum.reverse(&1.messages))
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

  def send_message(channel_pid, from_user, message) do
    update_func = fn(%Channel{users: users, name: name, messages: messages} = channel) ->
      users
      |> Map.values
      |> Enum.each(fn pid -> 
        send(pid, {:channel_message, name, from_user, message})
      end)
      
      %{channel | messages: [message | messages]}
    end

    Agent.update(channel_pid, update_func)
  end
end