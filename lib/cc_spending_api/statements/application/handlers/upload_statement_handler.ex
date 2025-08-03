defmodule CcSpendingApi.Statements.Application.Handlers.UploadStatementHandler do
  alias CcSpendingApi.Statements.Domain.CardStatementRepo
  alias CcSpendingApi.Statements.Domain.TransactionRepo
  alias CcSpendingApi.Statements.Application.Commands.UploadStatementTransaction

  @type deps :: %{
          card_repository: CardStatementRepo.t(),
          txn_repository: TransactionRepo.t(),
          transaction_fn: function() | nil
        }

  def handle(%UploadStatementTransaction{} = command, deps) do
    transaction_fn = deps[:transaction_fn] || (&default_transaction/1)

    transaction_fn.(fn ->
      nil
    end)
  end

  defp default_transaction(fun) do
    Repo.transaction(fun)
  end
end
