defmodule CcSpendingApi.Authentication.Application.Handlers.RegisterUserHandler do
  alias CcSpendingApi.Shared.{Result, Errors}
  alias CcSpendingApi.Authentication.Domain.Entities.User
  alias CcSpendingApi.Authentication.Application.Commands.RegisterUser
  alias CcSpendingApi.Authentication.Domain.Repositories.UserRepository
  alias CcSpendingApi.Authentication.Domain.Services.AuthenticationService

  alias CcSpendingApi.Repo

  @type deps :: %{
          user_repository: UserRepository.t(),
          session_repository: SessionRepository.t(),
          transaction_fn: function() | nil
        }

  def handle(%RegisterUser{} = command, deps) do
    transaction_fn = deps[:transaction_fn] || (&default_transaction/1)

    result =
      transaction_fn.(fn ->
        with false <- deps.user_repository.email_exists?(command.email),
             {:ok, user} <- User.new(%{email: command.email, password: command.password}),
             {:ok, saved_user} <- deps.user_repository.save(user),
             {:ok, {session, token}} <- AuthenticationService.create_session(saved_user, deps) do
          Result.ok(%{user: saved_user, session: session, token: token})
        else
          true ->
            Result.error(%Errors.ValidationError{
              message: "Email already exists",
              field: :email,
              value: command.email
            })

          error ->
            error
        end
      end)

    # unwrap since `Repo.transaction` wrap it into ok/error tuple
    case result do
      {:ok, result} -> result
      {:error, _} = error -> error
    end
  end

  defp default_transaction(fun) do
    Repo.transaction(fun)
  end
end
