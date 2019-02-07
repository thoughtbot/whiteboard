defmodule WhiteboardWeb.BoardControllerTest do
  use WhiteboardWeb.ConnCase, async: true

  test "GET /board/:id", %{conn: conn} do
    board = insert_board("name")

    conn =
      conn
      |> sign_in()
      |> get(Routes.board_path(conn, :show, board))

    assert html_response(conn, 200) =~ board.name
  end
end
