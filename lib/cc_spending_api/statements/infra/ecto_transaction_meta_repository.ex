defmodule CcSpendingApi.Statements.Infra.EctoTransactionMetaRepository do
  @behaviour CcSpendingApi.Statements.Domain.TransactionRepo

  import Ecto.Query
  alias CcSpendingApi.Repo
  alias CcSpendingApi.Shared.Result
  alias CcSpendingApi.Statements.Infra.Schemas.TransactionMetaSchema

  def create_batch_transaction(txn_metas) do
    case Repo.insert_all(TransactionMetaSchema, txn_metas, returning: true) do
      {:error, changeset} -> {:error, changeset}
      {_, inserted_txns} -> {:ok, inserted_txns}
    end
  end
end
