defmodule WhiteboardTest do
  use Whiteboard.DataCase, async: true

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
end
