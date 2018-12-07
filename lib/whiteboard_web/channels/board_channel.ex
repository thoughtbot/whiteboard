defmodule WhiteboardWeb.BoardChannel do
  use Phoenix.Channel

  def join("board:" <> board_id, _msg, socket) do
    board_paths = Whiteboard.all_paths(board_id)

    {:ok, board_paths, assign(socket, :board_id, board_id)}
  end

  def handle_in("new_event", payload, socket) do
    email = socket.assigns.email
    board_id = socket.assigns.board_id

    new_payload = Map.put(payload, :email, email)

    broadcast_from!(socket, "new_event", new_payload)

    %{"id" => path_id, "points" => points} = new_payload

    Whiteboard.upsert_path(board_id, path_id, email, points)

    {:noreply, socket}
  end
end
