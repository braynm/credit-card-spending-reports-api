defmodule CcSpendingApi.Statements do
  alias CcSpendingApi.Statements.Application.Commands.UploadStatementTransaction
  alias CcSpendingApi.Statements.Application.Handlers.UploadStatementHandler
  alias CcSpendingApi.Statements.Domain.Services.StatementProcessingServices

  alias CcSpendingApi.Statements.Domain.Services.ListUserTransaction

  alias CcSpendingApi.Statements.Application.Commands.ListUserTransaction,
    as: ListUserTransactionCommand

  def upload_and_save_transactions_from_attachment(params, deps \\ default_deps())

  def upload_and_save_transactions_from_attachment(params, deps) do
    with {:ok, command} <- UploadStatementTransaction.new(params) do
      UploadStatementHandler.handle(command, deps)
    end
  end

  def list_user_transaction(user_id, params \\ [], deps \\ [])

  def list_user_transaction(user_id, params, deps) do
    params = Keyword.put(params, :user_id, user_id)
    ListUserTransactionCommand.new(params)
  end

  defp default_deps, do: StatementProcessingServices.default()
end
