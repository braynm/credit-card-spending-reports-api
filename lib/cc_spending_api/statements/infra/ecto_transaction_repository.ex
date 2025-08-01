defmodule CcSpendingApi.Statements.Infra.EctoTransactionRepository do
  @behaviour CcSpendingApi.Statements.Domain.TransactionRepo

  import Ecto.Query
  alias CcSpendingApi.Repo
  alias CcSpendingApi.Shared.Result
  alias CcSpendingApi.Statements.Domain.Entities.Transaction
  alias CcSpendingApi.Statements.Infra.Schemas.TransactionSchema

  def create_batch_transaction(txns) do
    case Repo.insert_all(TransactionSchema, txns, returning: true) do
      # {:ok, inserted_txns} -> {:ok, Enum.map(inserted_txns, &to_domain/1)}
      {:error, changeset} -> {:error, changeset}
      {_, inserted_txns} -> {:ok, Enum.map(inserted_txns, &to_domain/1)}
    end
  end

  defp to_domain(%TransactionSchema{} = schema) do
    {:ok, txn} = Transaction.new(schema)

    txn
  end
end
