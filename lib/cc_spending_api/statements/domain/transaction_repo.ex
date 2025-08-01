defmodule CcSpendingApi.Statements.Domain.TransactionRepo do
  @callback create_batch_transaction(map()) :: {:ok, [map()]} | {:error, map()}
end
