defmodule Whiteboard.Repo.Migrations.CreateBoards do
  use Ecto.Migration

  def change do
    create table(:boards, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string

      timestamps()
    end
  end
end
