defmodule ChatexCore.Model.ChannelTest do
  use ExUnit.Case
  alias ChatexCore.Model.Channel
  alias ChatexCore.Model.User
  doctest Channel

  test "Can create new channel without name or users" do
    assert %Channel{} == Channel.new
  end

  test "Can create new channel with predefined users" do
    users = [User.new("pesho"), User.new("gosho")]
    channel = Channel.new("", users)
    assert Enum.member?(Channel.list_users(channel), User.new("pesho"))
    assert Enum.member?(Channel.list_users(channel), User.new("gosho"))
  end

  test "Can add user" do
    channel = Channel.new |> Channel.add_user(User.new("gosho"))
    assert Enum.member?(Channel.list_users(channel), User.new("gosho"))
  end

  test "Can remove user" do
    user = User.new("gosho")
    channel = Channel.new 
              |> Channel.add_user(user)
              |> Channel.add_user(User.new("gosho"))
              |> Channel.remove_user(user)

    assert channel |> Channel.list_users |> Enum.member?(user) == false
  end
end
