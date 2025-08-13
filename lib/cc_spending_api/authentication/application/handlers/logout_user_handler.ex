defmodule CcSpendingApi.Authentication.Application.Handlers.LogoutUserHandler do
  alias CcSpendingApi.Authentication.Application.Commands.LogoutUser
  alias CcSpendingApi.Authentication.Domain.Services.AuthenticationService

  @type deps :: %{
          session_repository: SessionRepository.t()
        }

  def handle(%LogoutUser{} = command, deps) do
    AuthenticationService.logout(command.token, deps)
  end
end
