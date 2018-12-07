defmodule WhiteboardWeb.BoardChannel do
  use Phoenix.Channel

  def join("board:" <> board_id, _msg, socket) do
    board_paths = Whiteboard.all_paths(board_id)

    {:ok, board_paths, assign(socket, :board_id, board_id)}
  end

  def handle_in("new_event", payload, socket) do
    broadcast_from!(socket, "new_event", payload)

    %{"id" => path_id, "points" => points} = payload

    Whiteboard.upsert_path(socket.assigns.board_id, path_id, points)

    {:noreply, socket}
  end
end
