use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :whiteboard, WhiteboardWeb.Endpoint,
  http: [port: 4002],
  server: true

config :whiteboard, :sql_sandbox, true

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :whiteboard, Whiteboard.Repo,
  username: "postgres",
  password: "postgres",
  database: "whiteboard_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
