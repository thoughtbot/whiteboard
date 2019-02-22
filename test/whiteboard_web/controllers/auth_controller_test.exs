defmodule WhiteboardWeb.AuthControllerTest do
  use WhiteboardWeb.ConnCase, async: true
  
  import Mox

  setup :verify_on_exit!

  test "GET index redirect to auth url", %{conn: conn} do
    Whiteboard.AuthMock
    |> expect(:authorize_url!, fn _ -> "example.com/auth" end) 

    conn =
      conn
      |> get(Routes.auth_path(conn, :index))

    assert redirected_to(conn) =~ "example.com/auth" 
  end
end
