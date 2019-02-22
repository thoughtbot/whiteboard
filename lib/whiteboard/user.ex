defmodule Whiteboard.User do
  use Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string

    timestamps()
  end
  
  def new(email) do
    %__MODULE__{email: email}
  end

  def create_changeset(struct, params) do
    struct
    |> cast(params, [:name, :email])
    |> validate_required([:name, :email])
  end
end
