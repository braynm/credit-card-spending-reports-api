defmodule CcSpendingApi.Statements.Application.Services.DuplicateChecker do
  @moduledoc """
  Service for checking duplicate statement uploads
  """

  alias CcSpendingApi.Statements.Infra.CardStatementRepo
  alias CcSpendingApi.Statements.Domain.ValueObjects.FileChecksum

  def check_duplicate(user_id, %FileChecksum{} = checksum) do
    checksum_string = FileChecksum.to_string(checksum)

    case CardStatementRepo.find_by_checksum(user_id, checksum_string) do
      nil ->
        {:ok, :not_duplicate}

      existing_statement ->
        {:error, {:duplicate_statement, card_id: existing_statement.card_id}}
    end
  end
end
