defmodule WhiteboardWeb.AuthControllerTest do
  use WhiteboardWeb.ConnCase, async: true
  
  import Mox

  alias Whiteboard.{Repo, User}

  setup :verify_on_exit!

  test "GET index redirect to auth url", %{conn: conn} do
    Whiteboard.AuthMock
    |> expect(:authorize_url!, fn _ -> "example.com/auth" end) 

    conn =
      conn
      |> get(Routes.auth_path(conn, :index))

    assert redirected_to(conn) =~ "example.com/auth" 
  end

  describe "GET callback" do
    test "save user info", %{conn: conn} do
      user_info = %{"email" => "test@example.com", "name" => "Test Smith"}
      Whiteboard.AuthMock
      |> expect(:get_token!, fn _, _ -> "fake token" end)
      |> expect(:get_user_info!, fn _ -> user_info end)

      conn
      |> get(Routes.auth_path(conn, :callback, %{"code" => "auth_code"}))

      assert user = Repo.get_by(User, email: user_info["email"])
      assert user.name == user_info["name"]
    end

    test "redirects to board path on success", %{conn: conn} do
      user_info = %{"email" => "test@example.com", "name" => "Test Smith"}
      Whiteboard.AuthMock
      |> expect(:get_token!, fn _, _ -> "fake token" end)
      |> expect(:get_user_info!, fn _ -> user_info end)

      conn =
        conn
        |> get(Routes.auth_path(conn, :callback, %{"code" => "auth_code"}))

      assert redirected_to(conn) =~ Routes.board_path(conn, :new)
    end

    test "redirects to login on failure", %{conn: conn} do
      conn =
        conn
        |> get(Routes.auth_path(conn, :callback, %{}))

      assert redirected_to(conn) =~ Routes.session_path(conn, :new)
      assert get_flash(conn, :error) =~ "Login failed" 
    end
  end
end
