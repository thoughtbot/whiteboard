defmodule WhiteboardWeb.BoardChannel do
  use Phoenix.Channel

  def join("board:" <> board_id, _msg, socket) do
    {:ok, assign(socket, :board_id, board_id)}
  end

  def handle_in("new_event", payload, socket) do
    broadcast_from!(socket, "new_event", payload)
    {:noreply, socket}
  end
end
