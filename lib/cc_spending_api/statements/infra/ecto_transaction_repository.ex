defmodule CcSpendingApi.Statements.Infra.EctoTransactionRepository do
  @behaviour CcSpendingApi.Statements.Domain.TransactionRepo

  import Ecto.Query
  alias CcSpendingApi.Repo
  alias CcSpendingApi.Shared.Result
  alias CcSpendingApi.Statements.Domain.Entities.Transaction
  alias CcSpendingApi.Statements.Infra.Schemas.TransactionSchema

  def create_batch_transaction(txns) do
    case Repo.insert_all(TransactionSchema, txns, returning: true) do
      {:error, changeset} -> {:error, changeset}
      {_, inserted_txns} -> {:ok, Enum.map(inserted_txns, &to_domain/1)}
    end
  end

  defp to_domain(%TransactionSchema{} = schema) do
    {:ok, txn} = Transaction.from_schema(schema)
    txn
  end

  defp to_domain(params) do
    IO.inspect(params)
    # {:ok, txn} = Transaction.from_schema(schema)
    params
  end

  def list_user_transaction(user_id) do
    from t in Transaction,
         where(t.user_id == ^user_id)
  end
end
