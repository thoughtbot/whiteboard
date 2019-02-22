defmodule Whiteboard.GoogleAuth do 
  import OAuth2.Client, only: [put_param: 3, put_header: 3]
  @behaviour Whiteboard.Auth

  @oauth_scopes "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile"

  def client(redirect_uri) do
    OAuth2.Client.new(
      strategy: OAuth2.Strategy.AuthCode,
      client_id: Application.get_env(:whiteboard, :auth_client_id),
      client_secret: Application.get_env(:whiteboard, :auth_client_secret),
      authorize_url: "https://accounts.google.com/o/oauth2/auth",
      token_url: "https://www.googleapis.com/oauth2/v3/token",
      site: "https://www.googleapis.com",
      redirect_uri: redirect_uri
    )
  end

  def authorize_url!(redirect_uri) do
    redirect_uri
    |> client()
    |> put_param(:scope, @oauth_scopes)
    |> OAuth2.Client.authorize_url!()
  end

  def get_token!(code, redirect_url) do
    redirect_url
    |> client()
    |> put_param(:client_secret, Application.get_env(:whiteboard, :auth_client_secret))
    |> OAuth2.Client.get_token!([code: code], [{"Accept", "application/json"}])
  end

  def get_userinfo!(token) do
    OAuth2.Client.get!(token, "/oauth2/v1/userinfo?alt=json").body
  end
end
