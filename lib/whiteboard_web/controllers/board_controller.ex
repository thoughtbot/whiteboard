defmodule WhiteboardWeb.BoardController do
  use WhiteboardWeb, :controller

  def show(conn, %{"id" => id}) do
    board = Whiteboard.get_board!(id)

    render(conn, "show.html", board: board)
  end

  def create(conn, %{"name" => name}) do
    case Whiteboard.create_board(name) do
      {:ok, board} ->
        redirect(conn, to: Routes.board_path(conn, :show, board))

      {:error, _changeset} ->
        conn
        |> put_view(Whiteboard.PageView)
        |> render("index.html")
    end
  end
end
