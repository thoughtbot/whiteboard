defmodule Whiteboard.Session do
  import Plug.Conn

  @one_year_in_seconds 365 * 24 * 60 * 60
  @one_week 86400 * 7
  @salt "user_id"

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

  def sign_user_id(conn, user_id) do
    signed_user_id = Phoenix.Token.sign(conn, @salt, user_id)
    conn |> Plug.Conn.put_resp_cookie("user_id", signed_user_id, max_age: @one_year_in_seconds)
  end

  def verify_signed_user_id(conn) do
    Phoenix.Token.verify(conn, @salt, conn.cookies["user_id"], max_age: @one_week)
  end
end
