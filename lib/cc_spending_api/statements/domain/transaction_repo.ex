defmodule CcSpendingApi.Statements.Domain.TransactionRepo do
  @callback batch_save_transaction(map()) :: {:ok, [map()]} | {:error, map()}
end
