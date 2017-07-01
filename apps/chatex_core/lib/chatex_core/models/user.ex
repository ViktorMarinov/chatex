defmodule ChatexCore.Model.User do
  @enforce_keys [:username]
  defstruct [:username]

  alias ChatexCore.Model.User

  def new(username) do
    %User{username: username}
  end

   # use Ecto.Schema

  # schema "users" do
  #   field :username, :string
  #   field :first_name, :string
  #   field :last_name, :string
  #   field :age, :integer
  #   many_to_many :channels, ChatexCore.Model.Channel, join_through: "users_channels",
  #                join_keys: [user_username: :username, channel_id: :id]
  # end
end