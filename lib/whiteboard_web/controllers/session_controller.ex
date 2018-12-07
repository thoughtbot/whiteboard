defmodule WhiteboardWeb.SessionController do
  use WhiteboardWeb, :controller

  alias Whiteboard.Session

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"email" => email}) do
    signed_in = Session.sign_in(conn, as: email)
    return_path = Session.return_to_or_default(conn, Routes.board_path(signed_in, :new))

    redirect(signed_in, to: return_path)
  end

  def delete(conn, _) do
    signed_out = Session.sign_out(conn)

    redirect(signed_out, to: Routes.session_path(signed_out, :new))
  end
end
