defmodule Whiteboard do
  alias Whiteboard.{Board, Repo}

  def create_board(name) do
    %Board{}
    |> Board.changeset(%{"name" => name})
    |> Repo.insert()
  end
end
