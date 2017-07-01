defmodule ChatexCore.UserRegistryTest do
  use ExUnit.Case
  alias ChatexCore.UserRegistry
  alias ChatexCore.Model.User
  doctest UserRegistry

  describe "start_link" do
    test "Can start and stop the UserRegistry process" do
      {:ok, pid} = UserRegistry.start_link(:test_user_registry)

      assert Process.alive?(pid)
      UserRegistry.stop(:test_user_registry)
    end
  end

  describe "user operations" do
    setup do
      {:ok, pid} = UserRegistry.start_link(:test_user_registry)
      {:ok, pid: pid}
    end

    test "Can register new user" do
      user = User.new("gosho")
      assert :test_user_registry |> UserRegistry.register_user(user) == {:registered, user}
    end

    test "Can get all users" do
      user1 = User.new("gosho")
      user2 = User.new("pesho")
      :test_user_registry |> UserRegistry.register_user(user1)
      :test_user_registry |> UserRegistry.register_user(user2)
      assert Map.equal?(
              UserRegistry.get_users(:test_user_registry),
              %{"gosho" => user1,
                "pesho" => user2})

    end

    test "Can get user by username" do
      user = User.new("gosho")
      :test_user_registry |> UserRegistry.register_user(user)
      assert :test_user_registry|> UserRegistry.get_user(user.username) == user
    end

    test "Can delete user", %{pid: pid} do
      user = User.new("gosho")
      assert :test_user_registry |> UserRegistry.register_user(user) == {:registered, user}
      assert :test_user_registry |> UserRegistry.delete_user("gosho")
      
      :sys.get_state(pid)

      assert :test_user_registry|> UserRegistry.get_user(user.username) == nil
    end
  end
end
