defmodule Whiteboard.Factory do
  def insert_board(name \\ "random board") do
    {:ok, board} = Whiteboard.create_board(name)
    board
  end

  def insert_path(board, points, email) do
    path_id = Ecto.UUID.generate()
    {:ok, path} = Whiteboard.upsert_path(board.id, path_id, email, points)
    path
  end
end
