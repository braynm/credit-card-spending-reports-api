defmodule CcSpendingApi.CcSpendingApi.Authentication.AuthenticationTest do
  use ExUnit.Case, async: true
  # use ExUnit.Case

  alias CcSpendingApi.Authentication
  alias CcSpendingApi.Test.Doubles

  alias CcSpendingApi.Authentication.Domain.ValueObjects.Email
  alias CcSpendingApi.Authentication.Domain.Entities.{User, Session}
  alias CcSpendingApi.Shared.{Result, Errors}

  # setup do
  #   # Set to shared mode for this test
  #   Ecto.Adapters.SQL.Sandbox.mode(CcSpendingApi.Repo, {:shared, self()})
  #
  #   on_exit(fn ->
  #     Ecto.Adapters.SQL.Sandbox.mode(CcSpendingApi.Repo, :manual)
  #   end)
  #
  #   :ok
  # end

  @tag :authentication
  describe "Authentication.register/4" do
    @tag :authentication
    test "successfully registers user and returns session" do
      deps = %{
        user_repository: Doubles.user_repository_double(),
        session_repository: Doubles.session_repository_double(),
        transaction_fn: Doubles.transaction_fn()
      }

      assert {:ok,
              %{
                user: %User{email: %Email{value: "test@example.com"}},
                session: %Session{id: "test-session-id", aud: "web"},
                token: "test-token"
              }} = Authentication.register("test@example.com", "password123", "web", deps)
    end

    @tag :authentication
    test "fails register on existing email and returns error" do
      user_repo = Doubles.user_repository_double(email_exists?: fn _email -> true end)

      deps = %{
        user_repository: user_repo,
        session_repository: Doubles.session_repository_double(),
        transaction_fn: Doubles.transaction_fn()
      }

      assert Result.error(%Errors.ValidationError{
               message: "Email already exists",
               field: :email,
               value: "test@example.com"
             }) == Authentication.register("test@example.com", "password123", "web", deps)
    end
  end
end
