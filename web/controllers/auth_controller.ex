defmodule PhoenixChat.AuthController do
  use PhoenixChat.Web, :controller

  alias PhoenixChat.{ErrorView, UserView, User, AuthController}

  plug Ueberauth
  plug Guardian.Plug.EnsureAuthenticated, [handler: AuthController] when action in [:delete, :me]

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    result = with {:ok, user} <- user_from_auth(auth),
                  :ok <- validate_pass(user.encrypted_password, auth.credentials.other.password),
                  do: signin_user(conn, user)

    case result do
      {:ok, user, token} ->
        conn
        |> put_status(:created)
        |> render(UserView, "show.json", user: user, token: token)
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> render(ErrorView, "error.json", error: reason)
    end
  end

  defp user_from_auth(auth) do
    result = Repo.get_by(User, email: auth.info.email)
    case result do
      nil -> {:error, %{"email" => ["invalid email"]}}
      user -> {:ok, user}
    end
  end

  defp validate_pass(_encrypted, password) when password in [nil, ""] do
    {:error, "password required"}
  end

  defp validate_pass(encrypted, password) do
    if Comeonin.Bcrypt.checkpw(password, encrypted) do
      :ok
    else
      {:error, "invalid password"}
    end
  end

  defp signin_user(conn, user) do
    token = conn
            |> Guardian.Plug.api_sign_in(user)
            |> Guardian.Plug.current_token
    {:ok, user, token}
  end

  def me(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    org = Repo.preload(user, :organization).organization || Repo.preload(user, :owned_organization).owned_organization
    case org do
      nil -> render(conn, UserView, "show.json", user: user)
      org -> render(conn, UserView, "show.json", user: user, org: org)
    end
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:unauthorized)
    |> render(ErrorView, "error.json", errors: %{"account" => ["insufficient privilege"]})
  end

  def unauthorized(conn, _params) do
    conn
    |> put_status(:forbidden)
    |> render(ErrorView, "error.json", error: %{"account" => ["unauthorized"]})
  end
  
end