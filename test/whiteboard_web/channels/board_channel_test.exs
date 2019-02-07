defmodule WhiteboardWeb.BoardChannelTest do
  use WhiteboardWeb.ChannelCase

  import Whiteboard.Factory

  alias WhiteboardWeb.BoardChannel

  describe "new_event" do
    test "broadcast new even to all participants" do
      payload = %{"id" => Ecto.UUID.generate(), "points" => [%{x: 1, y: 2}]}
      board = insert_board()

      board.id
      |> join_channel(as: "sample@example.com")
      |> send_new_event(payload)

      assert_broadcast("new_event", payload)
    end
  end

  def send_new_event({:ok, _reply, socket}, payload) do
    push(socket, "new_event", payload)
  end

  defp join_channel(board_id, as: email) do
    WhiteboardWeb.UserSocket
    |> socket("user_id", %{email: email})
    |> subscribe_and_join(BoardChannel, "board:" <> board_id)
  end
end
