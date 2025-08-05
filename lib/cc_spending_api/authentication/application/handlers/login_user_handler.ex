defmodule CcSpendingApi.Authentication.Application.Handlers.LoginUserHandler do
  alias CcSpendingApi.Authentication.Application.Commands.LoginUser
  alias CcSpendingApi.Authentication.Domain.Services.AuthenticationService
  alias CcSpendingApi.Authentication.Domain.ValueObjects.AuthenticatedUser
  alias CcSpendingApi.Shared.Result

  @type deps :: %{
          user_repository: UserRepository.t(),
          session_repository: SessionRepository.t()
        }

  def handle(%LoginUser{} = command, deps) do
    with {:ok, user} <- AuthenticationService.authenticate(command.email, command.password, deps),
         {:ok, session} <- AuthenticationService.create_session(user, deps) do
      Result.ok(%{
        user: AuthenticatedUser.new(user),
        # TODO: create session DTO
        session: session
      })
    else
      error -> error
    end
  end
end
