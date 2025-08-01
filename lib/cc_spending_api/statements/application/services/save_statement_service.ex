defmodule CcSpendingApi.Statements.Application.Services.SaveStatementService do
  alias CcSpendingApi.Shared.{Result, Errors}
  alias CcSpendingApi.Statements.Domain.Entities.CardStatement
  alias CcSpendingApi.Statements.Infra.EctoTransactionRepository
  alias CcSpendingApi.Statements.Infra.EctoCardStatementRepository
  alias CcSpendingApi.Statements.Domain.ValueObjects.FileChecksum

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
         {:ok, {count, inserted_txns}} <- create_batch(user_id, inserted_stmt.id, txns) do
      {:ok, inserted_txns}
    end
  end

  defp save_statement(statement_entity) do
    EctoCardStatementRepository.save_statement(statement_entity)
  end

  defp create_batch(user_id, statement_id, txns) do
    txns =
      Enum.map(
        txns,
        &Map.merge(&1, %{user_id: String.to_integer(user_id), statement_id: statement_id})
      )

    EctoTransactionRepository.create_batch_transaction(txns)
  end
end
