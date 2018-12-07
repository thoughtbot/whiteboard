defmodule WhiteboardWeb.BoardChannelTest do
  use WhiteboardWeb.ChannelCase

  alias Whiteboard.Board.Path
  alias Whiteboard.Repo
  alias WhiteboardWeb.BoardChannel

  describe "new_event" do
    test "broadcast new even to all participants" do
      payload = %{"id" => Ecto.UUID.generate(), "points" => [%{x: 1, y: 2}]}

      "random board"
      |> join_channel()
      |> send_new_event(payload)

      assert_broadcast("new_event", payload)
    end
  end

  def send_new_event({:ok, _reply, socket}, payload) do
    push(socket, "new_event", payload)
  end

  defp join_channel(board_name) do
    WhiteboardWeb.UserSocket
    |> socket("user_id", %{})
    |> subscribe_and_join(BoardChannel, "board:" <> board_name)
  end
end
