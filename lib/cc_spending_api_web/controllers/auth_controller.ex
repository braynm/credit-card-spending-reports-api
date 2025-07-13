defmodule CcSpendingApiWeb.AuthController do
  use CcSpendingApiWeb, :controller

  alias CcSpendingApi.Authentication
  alias CcSpendingApiWeb.Guardian

  def register(conn, params) do
    IO.inspect(params)
    audience = Map.get(params, "audience", "web")

    case Authentication.register(params["email"], params["password"], audience) do
      {:ok, %{user: user, session: {_session, token}}} ->
        user =
          user
          |> Map.from_struct()
          |> IO.inspect()
          |> Map.update(:email, nil, & &1.value)
          |> Map.drop([:password_hash])

        conn
        |> put_status(:created)
        |> json(%{user: user, token: token})

      {:error, error} ->
        conn
        |> put_status(400)
        |> json(%{
          error:
            error
            |> Map.from_struct()
            |> Map.drop([:__exception__])
        })
    end
  end

  def login(conn, %{"email" => email, "password" => password} = params) do
    audience = Map.get(params, "audience", "web")

    case Authentication.login(email, password, audience) |> IO.inspect() do
      {:ok, %{user: user, session: {_, token}}} ->
        user =
          user
          |> Map.from_struct()
          |> IO.inspect()
          |> Map.update(:email, nil, & &1.value)
          |> Map.drop([:password_hash])

        conn
        |> put_status(:created)
        |> json(%{user: user, token: token})

      {:error, error} ->
        conn
        |> put_status(400)
        |> json(%{
          error:
            error
            |> Map.from_struct()
            |> Map.drop([:__exception__])
        })
    end
  end

  def logout(conn, _params) do
    token = Guardian.Plug.current_token(conn)

    case Authentication.logout(token) do
      {:ok, :ok} ->
        conn
        |> put_status(:ok)
        |> render(:logout_success, %{message: "Successfully logged out"})

      {:error, error} ->
        {:error, error}
    end
  end

  def logout_all(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    case Authentication.logout_all(user.id) do
      {:ok, :ok} ->
        conn
        |> put_status(:ok)
        |> render(:logout_success, %{message: "Successfully logged out from all devices"})

      {:error, error} ->
        {:error, error}
    end
  end

  def me(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    session = Guardian.Plug.current_claims(conn)

    conn
    |> put_status(:ok)
    |> json(%{
      user: %{user: user.email.value, created_at: user.created_at, updated_at: user.updated_at},
      session: session
    })
  end

  def test(conn, _) do
    json(conn, %{"Hello" => "WORLD"})
  end

  def sessions(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    case Authentication.get_user_sessions(user.id) do
      {:ok, sessions} ->
        conn
        |> put_status(:ok)
        |> render(:sessions, %{sessions: sessions})

      {:error, error} ->
        {:error, error}
    end
  end

  def refresh(conn, _params) do
    token = Guardian.Plug.current_token(conn)

    case Guardian.refresh(token) do
      {:ok, _old_token, {new_token, _new_claims}} ->
        case Authentication.validate_session(new_token) do
          {:ok, %{user: user, session: session}} ->
            conn
            |> put_status(:ok)
            |> render(:auth_success, %{user: user, session: session, token: new_token})

          {:error, error} ->
            {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  end
end
