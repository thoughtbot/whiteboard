defmodule WhiteboardWeb.Router do
  use WhiteboardWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WhiteboardWeb do
    pipe_through :browser

    get "/", BoardController, :new
    resources "/boards", BoardController, only: [:show, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end
end
