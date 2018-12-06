defmodule Whiteboard.Repo do
  use Ecto.Repo,
    otp_app: :whiteboard,
    adapter: Ecto.Adapters.Postgres
end
