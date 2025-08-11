defmodule CcSpendingApi.Statements.Domain.Services.ListUserTransactionService do
  alias CcSpendingApi.Statements.Infra.EctoTransactionRepository
  alias CcSpendingApi.Shared.Result

  alias CcSpendingApi.Statements.Application.Commands.ListUserTransaction,
    as: ListUserTransactionCommand

  def list_user_transaction(%ListUserTransactionCommand{} = command) do
    with {:ok, queryable} <- build_base_query(command) do
      queryable
    end
  end

  defp build_base_query(%ListUserTransactionCommand{} = command) do
    Result.ok(EctoTransactionRepository.list_user_transaction(command.user_id))
  end
end
