defmodule Whiteboard do
  alias Whiteboard.{Board, Repo}

  def get_board!(id), do: Repo.get!(Board, id)

  def create_board(name) do
    %Board{}
    |> Board.changeset(%{"name" => name})
    |> Repo.insert()
  end
end
