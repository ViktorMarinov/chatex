defmodule ChatexServer.Channel do
  @doc """
  An Agent holding channel's state.
  The state of the agent is a %Channel{} struct, which
  stores the name of the channel, owner of the channel,
  mapping between usernames and pids and messages, send to
  the channel.
  """

  alias ChatexServer.Channel

  require Logger

  @enforce_keys [:name, :owner]
  defstruct [:name,
            :owner,
            users: %{}, #{username: pid}
            messages: []] 

  @doc """
  Starts a new channel
  """
  def start_link(%Channel{} = channel) do
    Agent.start_link(fn -> channel end)
  end

  @doc """
  Gets the name of the channel
  """
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

  @doc """
  Returns the messages stored in the channel
  """
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