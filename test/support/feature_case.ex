defmodule WhiteboardWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL

      alias Whiteboard.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import WhiteboardWeb.Router.Helpers
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Whiteboard.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Whiteboard.Repo, {:shared, self()})
    end

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Whiteboard.Repo, self())
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    {:ok, session: session}
  end
end
