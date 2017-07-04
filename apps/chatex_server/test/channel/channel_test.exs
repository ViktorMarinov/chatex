defmodule ChatexServer.ChannelTest do
  use ExUnit.Case
  alias ChatexServer.Channel
  alias ChatexServer.User
  doctest Channel

  setup do
    {:ok, channel} = Channel.start_link(%Channel{
      name: "test_channel"
    })
    {:ok, channel: channel}
  end

  test "add users", %{channel: channel} do
    channel |> Channel.add_user(User.new("gosho"))
    channel |> Channel.add_user(User.new("pesho"))
    users = channel
            |> Channel.get_users
            |> Map.values
    assert Enum.member?(users, User.new("gosho"))
    assert Enum.member?(users, User.new("pesho"))
  end

  test "remove user", %{channel: channel} do
    user = User.new("pesho")
    Channel.add_user(channel, user)
    Channel.add_user(channel, User.new("gosho"))
    Channel.remove_user(channel, "pesho")

    assert channel 
           |> Channel.get_users 
           |> Map.values
           |> Enum.member?(user) == false
  end
end
