defmodule Whiteboard.Auth do
  @callback client(String.t) :: OAuth2.Client.t
  @callback authorize_url!(String.t) :: String.t
  @callback get_token!(String.t, String.t) :: String.t
  @callback get_userinfo!(String.t) :: map
end
