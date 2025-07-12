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
          transaction_fn: function()
        }

  def handle(%RegisterUser{} = command, deps) do
    # Repo.transaction(fn ->
    {:ok, result} =
      deps.transaction_fn(fn ->
        with false <- deps.user_repository.email_exists?(command.email),
             {:ok, user} <- User.new(%{email: command.email, password: command.password}),
             {:ok, saved_user} <- deps.user_repository.save(user),
             {:ok, session} <- AuthenticationService.create_session(saved_user, deps) do
          Result.ok(%{user: saved_user, session: session})
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

    result
  end
end
