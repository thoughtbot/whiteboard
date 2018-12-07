defmodule Whiteboard do
  alias Whiteboard.{Board, Repo}

  import Ecto.Query

  def get_board!(id), do: Repo.get!(Board, id)

  def create_board(name) do
    %Board{}
    |> Board.changeset(%{"name" => name})
    |> Repo.insert()
  end

  def all_paths(board_id) do
    Board.Path |> where([p], p.board_id == ^board_id) |> Repo.all()
  end

  def upsert_path(board_id, path_id, points) do
    changes = %{"board_id" => board_id, "id" => path_id, "points" => points}

    %Board.Path{}
    |> Board.Path.changeset(changes)
    |> Repo.insert(on_conflict: {:replace, [:points]}, conflict_target: :id)
  end
end
