defmodule WhiteboardWeb.PageController do
  use WhiteboardWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
