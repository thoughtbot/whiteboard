defmodule WhiteboardTest do
  use Whiteboard.DataCase, async: true

  import Whiteboard.Factory

  describe "new_board/1" do
    test "creates a new board with given name" do
      {:ok, board} = Whiteboard.create_board("hello board")

      assert board.name == "hello board"
    end

    test "returns error if no name is given" do
      {:error, changeset} = Whiteboard.create_board("")

      assert "can't be blank" in errors_on(changeset).name
    end
  end

  describe "upsert_path/3" do
    test "creates path if does not exist" do
      board = insert_board()
      path_id = Ecto.UUID.generate()
      points = [%{"x" => 1, "y" => 2}]

      {:ok, path} = Whiteboard.upsert_path(board.id, path_id, points)

      assert path.points == points
      assert path.board_id == board.id
      assert path.id == path_id
    end

    test "updates path if it exists" do
      board = insert_board()
      points = [%{"x" => 1, "y" => 2}]
      path = insert_path(board, points)

      new_points = [%{"x" => 3, "y" => 4}]

      {:ok, path} = Whiteboard.upsert_path(board.id, path.id, new_points)

      assert path.points == new_points
      assert path.board_id == board.id
    end
  end
end
