defmodule CcSpendingApi.Statements.Application.Handlers.ListUserTransactionHandler do
  alias CcSpendingApi.Statements.Application.Commands.ListUserTransaction
  alias CcSpendingApi.Shared.Result

  def handle(%ListUserTransaction{} = command, deps) do
    with {:ok, base_query} <- build_base_query(command) do
    end
  end

  defp build_base_query(command) do
    Result.ok(command)
  end
end
