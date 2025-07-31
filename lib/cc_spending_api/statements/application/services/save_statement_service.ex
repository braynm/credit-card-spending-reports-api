defmodule CcSpendingApi.Statements.Application.Services.SaveStatementService do
  alias CcSpendingApi.Shared.{Result, Errors}
  alias CcSpendingApi.Statements.Domain.Entities.CardStatement
  alias CcSpendingApi.Statements.Infra.EctoCardStatementRepository
  alias CcSpendingApi.Statements.Domain.ValueObjects.FileChecksum

  def save_statement_and_transaction(params) do
    %FileChecksum{value: checksum} = params["file_checksum"]

    params =
      params
      |> Map.put_new("user_id", 11)
      |> Map.put("file_checksum", checksum)

    with {:ok, statement_entity} <- CardStatement.new(params) do
      EctoCardStatementRepository.save_statement(statement_entity)
    end
  end
end
