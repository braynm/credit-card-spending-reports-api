defmodule CcSpendingApi.Statements.Domain.Services.ListUserTransaction do
  alias CcSpendingApi.Statements.Infra.EctoTransactionRepository
  alias CcSpendingApi.Shared.Result

  alias CcSpendingApi.Statements.Application.Commands.ListUserTransaction,
    as: ListUserTransactionCommand

  def list_user_transaction(%ListUserTransactionCommand{} = command) do
    command
  end

  defp build_base_query(%ListUserTransactionCommand{} = command) do
    Result.ok(EctoTransactionRepository.list_user_transaction(user_id))
  end
end
