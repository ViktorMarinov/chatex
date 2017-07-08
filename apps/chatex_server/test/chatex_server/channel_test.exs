defmodule ChatexServer.ChannelTest do
  use ExUnit.Case
  alias ChatexServer.Channel
  doctest Channel

  setup do
    {:ok, channel} = Channel.start_link(%Channel{
      owner: "test_user",
      name: "test_channel"
    })
    {:ok, channel: channel}
  end

  test "can add users", %{channel: channel} do
    channel |> Channel.add_user("gosho", :pid1)
    channel |> Channel.add_user("pesho", :pid2)

    assert Map.equal?(
      Channel.get_users(channel), 
      %{"gosho" => :pid1, "pesho" => :pid2}
    )
  end

  test "can remove user", %{channel: channel} do
    Channel.add_user(channel, "pesho", :pid1)
    Channel.add_user(channel, "gosho", :pid2)
    Channel.remove_user(channel, "pesho")

    assert channel 
           |> Channel.get_users 
           |> Map.keys
           |> Enum.member?("pesho") == false
  end

  test "channels store history", %{channel: channel} do
    Channel.send_message(channel, "viktor", "first")
    Channel.send_message(channel, "viktor", "second")
    Channel.send_message(channel, "viktor", "third")
    
    assert ["first", "second", "third"] == Channel.get_messages(channel)
  end
end
