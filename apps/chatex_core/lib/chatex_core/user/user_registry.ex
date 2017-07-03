defmodule ChatexCore.UserRegistry do
  use GenServer

  require Logger

  def start_link(name) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  def stop(registry) do
    GenServer.stop(registry)
  end

  def register_user(registry, user) do
    GenServer.call(registry, {:register, user})
  end

  def delete_user(registry, username) do
    GenServer.cast(registry, {:delete, username})
  end

  def get_users(registry) do
    GenServer.call(registry, {:get_all})
  end

  def get_user(registry, username) do
    GenServer.call(registry, {:get, username})
  end

  @doc """
    Server callbacks
  """
  
  def init(_) do
    Logger.debug("Initializing UserRegistry")
    {:ok, %{}}
  end

  def handle_call({:register, user}, _from, users) do
    if Map.has_key?(users, user.username) do
      Logger.info("Registering user #{user.username}.")
      {:reply, {:username_taken, user.username}, users}
    else
      {:reply, {:registered, user}, Map.put(users, user.username, user)}
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