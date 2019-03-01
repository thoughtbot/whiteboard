defmodule WhiteboardWeb.Router do
  use WhiteboardWeb, :router

  alias Whiteboard.{Repo, User, Session}

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :assign_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WhiteboardWeb do
    pipe_through :browser

    get "/", BoardController, :new, as: :board
    get "/auth/callback", AuthController, :callback
    resources "/auth", AuthController, only: [:index]
    resources "/boards", BoardController, only: [:show, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  def assign_current_user(conn, _) do
    user = case Session.verify_signed_user_id(conn) do
      {:ok, user_id} -> Repo.get(User, user_id)
      {:error, _} -> :not_signed_in
    end

    assign(conn, :current_user, user)
  end
end
