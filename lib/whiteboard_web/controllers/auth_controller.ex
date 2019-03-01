defmodule WhiteboardWeb.AuthController do
  use WhiteboardWeb, :controller

  alias Whiteboard.{Repo, User, Session}

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

    case find_or_insert_user(email, name) do
      nil ->
        conn
        |> put_flash(:error, "Login failed")
        |> redirect(external: Routes.session_path(conn, :new))

      user ->
        conn
        |> Session.sign_user_id(user.id)
        |> Session.sign_in(as: email)
        |> redirect(external: Session.return_to_or_default(conn, Routes.board_path(conn, :new)))
    end
  end

  def callback(conn, _params) do
    conn
    |> put_flash(:error, "Login failed")
    |> redirect(external: Routes.session_path(conn, :new))
  end

  defp find_or_insert_user(email, name) do
    Repo.get_by(User, email: email) || insert_new_user(email, name)
  end

  defp insert_new_user(email, name) do
    changeset = User.create_changeset(%User{}, %{email: email, name: name})

    case Repo.insert(changeset) do
      {:ok, user} ->
        user

      {:error, _changeset} ->
        nil
    end
  end
end
