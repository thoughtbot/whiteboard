defmodule Whiteboard.Repo.Migrations.AddEmailToPaths do
  use Ecto.Migration

  def change do
    execute "DELETE FROM paths"

    alter table("paths") do
      add :email, :string, null: false
    end
  end
end
