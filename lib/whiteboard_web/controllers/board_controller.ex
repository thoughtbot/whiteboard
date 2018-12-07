defmodule WhiteboardWeb.BoardController do
  use WhiteboardWeb, :controller

  alias Whiteboard.Session

  plug :authenticate

  def new(conn, _) do
    render(conn, "new.html")
  end

  def show(conn, %{"id" => id}) do
    board = Whiteboard.get_board!(id)

    render(conn, "show.html", board: board)
  end

  def create(conn, %{"name" => name}) do
    case Whiteboard.create_board(name) do
      {:ok, board} ->
        redirect(conn, to: Routes.board_path(conn, :show, board))

      {:error, _changeset} ->
        render(conn, "new.html")
    end
  end

  defp authenticate(conn, _params) do
    if Session.signed_in?(conn) do
      conn
    else
      conn
      |> Session.save_return_to(conn.request_path)
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end
end
