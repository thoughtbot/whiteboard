defmodule Whiteboard.Session do
  import Plug.Conn

  def sign_in(conn, as: email) do
    user = Whiteboard.User.new(email)
    put_session(conn, :current_user, user)
  end

  def signed_in?(conn) do
    !is_nil(current_user(conn))
  end

  def sign_out(conn) do
    delete_session(conn, :current_user)
  end

  def current_user(conn) do
    get_session(conn, :current_user)
  end

  def save_return_to(conn, path) do
    put_session(conn, :return_to, path)
  end

  def return_to_or_default(conn, default) do
    case get_session(conn, :return_to) do
      nil -> default
      found_path -> found_path
    end
  end

  def guest_user do
    Whiteboard.User.new("guest")
  end
end
