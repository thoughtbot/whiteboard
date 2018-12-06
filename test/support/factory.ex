defmodule Whiteboard.Factory do
  def insert_board(name) do
    {:ok, board} = Whiteboard.create_board(name)
    board
  end
end
