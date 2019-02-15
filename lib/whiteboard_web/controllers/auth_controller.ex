defmodule WhiteboardWeb.AuthController do
  use WhiteboardWeb, :controller

  alias Whiteboard.Auth

  require Logger

  def index(conn, _params) do
    redirect_url = Routes.auth_url(conn, :callback)

    conn
    |> redirect(external: Auth.authorize_url!(redirect_url))
  end

  def callback(conn, %{"code" => code}) do
    redirect_url = Routes.auth_url(conn, :callback)
    token = Auth.get_token!(code, redirect_url)

    conn
    |> redirect(external: Routes.session_path(conn, :new))
  end

  def callback(conn, params) do
    Logger.warn(fn -> "Error #{inspect(params)}" end)

    conn
    |> redirect(external: Routes.session_path(conn, :new))
  end
end
