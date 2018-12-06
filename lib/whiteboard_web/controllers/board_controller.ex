defmodule WhiteboardWeb.BoardController do
  use WhiteboardWeb, :controller

  def show(conn, %{"id" => id}) do
    board = Whiteboard.get_board!(id)

    render(conn, "show.html", board: board)
  end
end
