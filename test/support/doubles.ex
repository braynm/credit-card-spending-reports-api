defmodule CcSpendingApi.Test.Doubles do
  alias CcSpendingApi.Authentication.Domain.Repositories.{UserRepository, SessionRepository}
  alias CcSpendingApi.Authentication.Domain.Entities.{User, Session}
  alias CcSpendingApi.Shared.{Result, Errors}
  import Double

  def user_repository_double(overrides \\ []) do
    UserRepository
    |> stub(:save, fn user -> Result.ok(%{user | id: "test-user-id"}) end)
    |> stub(:get_by_email, fn _email ->
      Result.error(%Errors.NotFoundError{message: "User not found", resource: :user})
    end)
    |> stub(:get_by_id, fn _id ->
      Result.error(%Errors.NotFoundError{message: "User not found", resource: :user})
    end)
    |> stub(:email_exists?, fn _email -> false end)
    |> apply_overrides(overrides)
  end

  def session_repository_double(overrides \\ []) do
    test_session = %Session{
      id: "test-session-id",
      user_id: "test-user-id",
      jti: "test-jti",
      aud: "web",
      # 1 hour
      expires_at: DateTime.add(DateTime.utc_now(), 3600, :second)
    }

    SessionRepository
    |> Double.stub(:create_token, fn session ->
      Result.ok({%{session | id: "test-session-id"}, "test-token"})
    end)
    |> Double.stub(:validate_token, fn _token -> Result.ok(test_session) end)
    |> Double.stub(:revoke_token, fn _token -> Result.ok(:ok) end)
    |> Double.stub(:revoke_all_user_tokens, fn _user_id -> Result.ok(:ok) end)
    |> Double.stub(:get_user_sessions, fn _user_id -> Result.ok([test_session]) end)
    |> Double.stub(:cleanup_expired_tokens, fn -> Result.ok(0) end)
    |> apply_overrides(overrides)
  end

  defp apply_overrides(double, overrides) do
    Enum.reduce(overrides, double, fn {function, impl}, acc ->
      Double.stub(acc, function, impl)
    end)
  end
end
