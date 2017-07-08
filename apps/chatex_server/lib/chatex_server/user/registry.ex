defmodule ChatexServer.User.Registry do
  @moduledoc """
  This registry stores information about the registered users
  in Chatex server. It provides operations for registering, deleting and
  getting user information. The state is a map with usernames as keys 
  and %User{} structures as values.
  """
  
  use GenServer

  require Logger

  @doc """
  Starts the registry process and link it to the calling process.
  Should be called only by the main supervisor.
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  @doc """
  Stops the registry
  """
  def stop(registry) do
    GenServer.stop(registry)
  end

  @doc """
  Registers a new user to the registry
  """
  def register_user(registry, user) do
    GenServer.call(registry, {:register, user})
  end

  @doc """
  Deletes the user with the given username.
  Asynchronous operation that returns :ok, regardless of
  the success of the operation.
  """
  def delete_user(registry, username) do
    GenServer.cast(registry, {:delete, username})
  end

  @doc """
  Returns all the users stored in the registry
  """
  def get_users(registry) do
    GenServer.call(registry, {:get_all})
  end

  @doc """
  Gets user by the given username
  """
  def get_user(registry, username) do
    GenServer.call(registry, {:get, username})
  end

  @doc """
    Server callbacks
  """
  
  def init(_) do
    Logger.debug("Initializing User.Registry")
    {:ok, %{}}
  end

  def handle_call({:register, user}, _from, users) do
    if Map.has_key?(users, user.username) do
      {:reply, {:error, :username_taken}, users}
    else
      Logger.info("Registering user #{user.username}.")
      {:reply, {:registered, user.username}, Map.put(users, user.username, user)}
    end
  end

  def handle_call({:get_all}, _from, users) do
    {:reply, users, users}
  end

  def handle_call({:get, username}, _from, users) do
    {:reply, Map.get(users, username), users}
  end

  def handle_cast({:delete, username}, users) do
    {:noreply, Map.delete(users, username)}
  end
end