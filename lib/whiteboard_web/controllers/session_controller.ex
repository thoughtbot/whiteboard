defmodule WhiteboardWeb.SessionController do
  use WhiteboardWeb, :controller

  alias Whiteboard.Session

  def new(conn, _) do
    render(conn, "new.html")
  end

  def delete(conn, _) do
    signed_out = Session.sign_out(conn)

    redirect(signed_out, to: Routes.session_path(signed_out, :new))
  end
end
