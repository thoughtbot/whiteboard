defmodule WhiteboardWeb.AuthController do
  use WhiteboardWeb, :controller

  require Logger

  def index(conn, _params) do
    auth_module = Application.get_env(:whiteboard, :auth_module)
    redirect_url = Routes.auth_url(conn, :callback)

    conn
    |> redirect(external: auth_module.authorize_url!(redirect_url))
  end

  def callback(conn, %{"code" => code}) do
    auth_module = Application.get_env(:whiteboard, :auth_module)
    redirect_url = Routes.auth_url(conn, :callback)
    token = auth_module.get_token!(code, redirect_url)
    %{"email" => email, "name" => name} = auth_module.get_userinfo!(token)

    conn
    |> redirect(external: Routes.session_path(conn, :new))
  end

  def callback(conn, params) do
    Logger.warn(fn -> "Error #{inspect(params)}" end)

    conn
    |> redirect(external: Routes.session_path(conn, :new))
  end
end
