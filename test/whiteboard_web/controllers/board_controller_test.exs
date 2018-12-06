defmodule WhiteboardWeb.BoardControllerTest do
  use WhiteboardWeb.ConnCase

  test "GET /board/:id", %{conn: conn} do
    board = insert_board("name")

    conn = get(conn, "/boards/#{board.id}")

    assert html_response(conn, 200) =~ board.name
  end
end
