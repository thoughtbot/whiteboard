defmodule Whiteboard.Board.Path do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  @derive {Jason.Encoder, only: [:id, :points, :email]}
  schema "paths" do
    field :points, {:array, :map}
    field :email, :string
    belongs_to :board, Whiteboard.Board, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(path, attrs) do
    path
    |> cast(attrs, [:id, :points, :email, :board_id])
    |> validate_required([:id, :points, :email, :board_id])
  end
end
