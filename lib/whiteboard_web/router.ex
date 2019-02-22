defmodule WhiteboardWeb.Router do
  use WhiteboardWeb, :router

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
    user =
      if Whiteboard.Session.signed_in?(conn) do
        Whiteboard.Session.current_user(conn)
      else
        Whiteboard.Session.guest_user()
      end

    assign(conn, :current_user, user)
  end
end
