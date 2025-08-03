defmodule CcSpendingApi.Statements.Domain.Services.SaveStatementService do
  alias CcSpendingApi.Shared.{Result, Errors}
  alias CcSpendingApi.Statements.Infra.EctoTransactionRepository
  alias CcSpendingApi.Statements.Infra.EctoTransactionMetaRepository
  alias CcSpendingApi.Statements.Infra.EctoCardStatementRepository
  alias CcSpendingApi.Statements.Domain.ValueObjects.FileChecksum
  alias CcSpendingApi.Statements.Domain.Entities.CardStatement
  alias CcSpendingApi.Statements.Domain.Entities.StatementMeta
  alias CcSpendingApi.Statements.Domain.Entities.Transaction
  alias CcSpendingApi.Statements.Domain.Entities.TransactionMeta

  def save_statement_and_transaction(params) do
    txns = params["txns"]
    user_id = params["user_id"]
    %FileChecksum{value: checksum} = params["file_checksum"]

    card_stmt =
      params
      |> Map.take(["filename", "file_checksum", "user_id"])
      |> Map.put("file_checksum", checksum)

    with {:ok, statement_entity} <- CardStatement.new(card_stmt),
         {:ok, inserted_stmt} <- save_statement(statement_entity),
         {:ok, inserted_txns} <- create_batch(user_id, inserted_stmt.id, txns) do
      # IO.inspect(inserted_txns)
      {:ok, inserted_txns}
    end
  end

  defp save_statement(statement_entity) do
    EctoCardStatementRepository.save_statement(statement_entity)
  end

  defp create_batch(user_id, statement_id, txns) do
    txn_items =
      Enum.map(
        txns,
        &Map.merge(&1, %{user_id: String.to_integer(user_id), statement_id: statement_id})
      )

    with {:ok, inserted_txns} <-
           EctoTransactionRepository.create_batch_transaction(txn_items) do
      txn_metas = Enum.map(inserted_txns, &to_txn_metas_entity/1)

      IO.inspect(txn_metas)
      # side effect for reports
      {:ok, _} = EctoTransactionMetaRepository.create_batch_transaction(txn_metas)
      {:ok, inserted_txns}
    end
  end

  defp to_txn_metas_entity(%Transaction{} = item) do
    {:ok, txn_meta} = TransactionMeta.from_transaction(item)

    txn_meta
    |> Map.from_struct()
    |> Map.put(:id, Ecto.UUID.generate())
  end
end
