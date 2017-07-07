defmodule ChatexServer.User.RegistryTest do
  use ExUnit.Case
  alias ChatexServer.User.Registry
  alias ChatexServer.User
  doctest Registry

  describe "start_link" do
    test "Can start and stop the Registry process" do
      {:ok, pid} = Registry.start_link(:test_user_registry)

      assert Process.alive?(pid)
      Registry.stop(:test_user_registry)
      assert false == Process.alive?(pid) 
    end
  end

  describe "user operations" do
    setup do
      {:ok, pid} = Registry.start_link(:test_user_registry)
      {:ok, pid: pid}
    end

    test "register new user" do
      user = User.new("gosho", "pass")
      assert {:registered, "gosho"} == :test_user_registry |> Registry.register_user(user)
    end

    test "cannot register user if username is taken" do
      user = User.new("gosho", "pass")
      Registry.register_user(:test_user_registry, user)
      assert Registry.register_user(:test_user_registry, user) == {:error, :username_taken}
    end

    test "get all users" do
      user1 = User.new("gosho", "pass")
      user2 = User.new("pesho", "pass")
      :test_user_registry |> Registry.register_user(user1)
      :test_user_registry |> Registry.register_user(user2)
      assert Map.equal?(
              Registry.get_users(:test_user_registry),
              %{"gosho" => user1,
                "pesho" => user2})

    end

    test "get user by username" do
      user = User.new("gosho", "pass")
      :test_user_registry |> Registry.register_user(user)
      assert :test_user_registry |> Registry.get_user(user.username) == user
    end

    test "delete user", %{pid: pid} do
      user = User.new("gosho", "pass")
      Registry.register_user(:test_user_registry, user)
      assert :test_user_registry |> Registry.delete_user("gosho")
      
      :sys.get_state(pid)

      assert :test_user_registry|> Registry.get_user(user.username) == nil
    end
  end
end

