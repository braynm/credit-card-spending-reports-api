defmodule CcSpendingApi.Statements.Domain.CardStatementRepo do
  @callback find_by_checksum(integer, binary()) :: map() | nil
  @callback save_statement(map()) :: {:ok, map()} | {:error, map()}
end
