defmodule WhiteboardWeb.UserCreatesABoardTest do
  use WhiteboardWeb.FeatureCase, async: false

  import Wallaby.Query, only: [css: 2, text_field: 1, button: 1]

  test "users creates a board with a name", %{session: session} do
    name = "Super new board"

    session
    |> visit("/")
    |> sign_in()
    |> fill_in(text_field("Board"), with: name)
    |> click(button("Submit"))
    |> assert_has(css(".board-name", text: name))
  end
end
