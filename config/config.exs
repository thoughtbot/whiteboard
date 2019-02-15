# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :whiteboard,
  ecto_repos: [Whiteboard.Repo]

# Configures the endpoint
config :whiteboard, WhiteboardWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/n+Y4BlkZKu+OuOShmHkel+JpE/+vFS+jcCyWUBYY0s1AxAJJuu2h7RHY6ZDSHFN",
  render_errors: [view: WhiteboardWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Whiteboard.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :oauth2, serializers: %{"application/json" => Jason}

config :whiteboard,
  auth_client_id: System.get_env("CLIENT_ID"),
  auth_client_secret: System.get_env("CLIENT_SECRET"),
  auth_redirect_uri: System.get_env("redirect_uri")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
