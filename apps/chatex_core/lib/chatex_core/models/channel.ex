defmodule ChatexCore.Model.Channel do
  alias ChatexCore.Model.Channel
  
  # use Ecto.Schema

  # schema "channels" do
  #   field :name, :string
  #   many_to_many :users, ChatexCore.Model.User, 
  #                join_through: "users_channels"
  # end

  defstruct name: "",
            users: %MapSet{}

  def new(name \\ "", users \\ []) when is_list(users) do
    %Channel{name: name, users: Enum.into(users, %MapSet{})}
  end

  def list_users(%Channel{users: users}) do
    users |> Enum.into([])
  end

  def add_user(%Channel{users: users} = channel, user) do
    %{channel | users: MapSet.put(users, user)}
  end

  def remove_user(%Channel{users: users} = channel, user) do
    %{channel | users: MapSet.delete(users, user)}
  end
end