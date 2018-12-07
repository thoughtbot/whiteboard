defmodule Whiteboard.Repo.Migrations.CreatePaths do
  use Ecto.Migration

  def change do
    create table(:paths, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :board_id, references("boards", type: :uuid)
      add :points, {:array, :map}, default: [], null: false

      timestamps()
    end
  end
end
