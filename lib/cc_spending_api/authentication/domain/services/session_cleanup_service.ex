defmodule CcSpendingApi.Authentication.Domain.Services.SessionCleanupService do
  alias CcSpendingApi.Authentication.Domain.Repositories.SessionRepository
  alias CcSpendingApi.Shared.Result

  @type deps :: %{session_repository: SessionRepository.t()}

  def cleanup_expired_sessions(deps) do
    deps.session_repository.cleanup_expired_tokens()
  end
end
