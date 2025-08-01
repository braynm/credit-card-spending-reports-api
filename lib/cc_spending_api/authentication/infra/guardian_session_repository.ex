defmodule CcSpendingApi.Authentication.Infra.GuardianSessionRepository do
  @behaviour CcSpendingApi.Authentication.Domain.Repositories.SessionRepository

  alias CcSpendingApi.Authentication.Domain.Entities.{User, Session}
  alias CcSpendingApi.Authentication.Domain.ValueObjects.Email
  alias CcSpendingApi.Authentication.Infra.EctoUserRepository
  alias CcSpendingApiWeb.Guardian, as: GuardianWeb
  alias CcSpendingApi.Shared.{Result, Errors}
  alias Guardian.DB
  alias CcSpendingApi.Repo

  import Ecto.Query

  def create_token(%Session{} = session) do
    with {:ok, user} <- EctoUserRepository.get_by_id(session.user_id),
         {:ok, token, claims} <-
           GuardianWeb.encode_and_sign(
             user,
             %{},
             audience: session.aud,
             jti: session.jti
           ),
         updated_session <- update_session_from_claims(session, claims) do
      Result.ok({updated_session, token})
    else
      {:error, error} -> Result.error(error)
      error -> Result.error(error)
    end
  end

  def validate_token(token) when is_binary(token) do
    with {:ok, claims} <- GuardianWeb.decode_and_verify(token),
         {:ok, user} <- GuardianWeb.resource_from_claims(claims),
         {:ok, session} <- build_session_from_claims(claims, user) do
      Result.ok(session)
    else
      {:error, :token_not_found} ->
        Result.error(%Errors.AuthenticationError{message: "Invalid session"})

      {:error, :token_expired} ->
        Result.error(%Errors.AuthenticationError{message: "Session expired"})

      {:error, _reason} ->
        Result.error(%Errors.AuthenticationError{message: "Invalid session"})

      error ->
        Result.error(%Errors.AuthenticationError{message: "Session validation failed"})
    end
  end

  def revoke_token(token) when is_binary(token) do
    case GuardianWeb.revoke(token) do
      {:ok, _claims} -> Result.ok(:ok)
      {:error, _reason} -> Result.ok(:ok)
    end
  end

  def revoke_all_user_tokens(user_id) when is_binary(user_id) do
    with {:ok, user} <- EctoUserRepository.get_by_id(user_id) do
      case DB.revoke_all_tokens_for_user(user, GuardianWeb) do
        :ok -> Result.ok(:ok)
        {:error, reason} -> Result.error(reason)
      end
    else
      error -> error
    end
  end

  def get_user_sessions(user_id) when is_binary(user_id) do
    tokens =
      from(t in Guardian.DB.Token,
        where: t.sub == ^user_id and is_nil(t.revoked_at),
        order_by: [desc: t.inserted_at]
      )
      |> Repo.all()
      |> Enum.map(&to_session/1)

    Result.ok(tokens)
  end

  def cleanup_expired_tokens do
    case DB.purge_expired_tokens(GuardianWeb) do
      {count, _} -> Result.ok(count)
      error -> Result.error(error)
    end
  end

  defp update_session_from_claims(session, claims) do
    %{session | jti: claims["jti"], expires_at: DateTime.from_unix!(claims["exp"])}
  end

  defp build_session_from_claims(claims, user) do
    Session.new(%{
      user_id: user.id,
      jti: claims["jti"],
      exp: claims["exp"],
      typ: claims["typ"],
      access: claims["access"],
      sub: claims["sub"]
    })

    # {:ok, Session.new(session)}
  end

  # defp to_session(token) when is_struct(token, Guardian.DB.Token) do
  defp to_session(%Guardian.DB.Token{} = token) do
    {:ok, session} =
      Session.new(%{
        id: token.jti,
        user_id: token.sub,
        jti: token.jti,
        aud: token.aud,
        expires_at: DateTime.from_unix!(token.exp),
        created_at: token.inserted_at,
        updated_at: token.updated_at
      })

    session
  end
end
