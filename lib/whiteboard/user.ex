defmodule Whiteboard.User do
  defstruct [:email]

  def new(email) do
    %__MODULE__{email: email}
  end
end
