defmodule WhiteboardWeb.AuthController do
  use WhiteboardWeb, :controller

  alias Whiteboard.{Repo, User}

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
    %{"email" => email, "name" => name} = auth_module.get_user_info!(token)

    changeset = User.create_changeset(%User{}, %{email: email, name: name})

    case Repo.insert(changeset) do
      {:ok, _} ->
        conn
        |> redirect(external: Routes.board_path(conn, :new))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Login failed")
        |> redirect(external: Routes.session_path(conn, :new))
    end
  end

  def callback(conn, _params) do
    conn
    |> put_flash(:error, "Login failed")
    |> redirect(external: Routes.session_path(conn, :new))
  end
end
