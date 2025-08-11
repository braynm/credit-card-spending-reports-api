defmodule CcSpendingApi.Statements.Application.Handlers.ListUserTransactionHandler do
  alias CcSpendingApi.Repo
  alias CcSpendingApi.Shared.Result
  alias CcSpendingApi.Shared.Pagination
  alias CcSpendingApi.Shared.Pagination.Metadata
  alias CcSpendingApi.Shared.Pagination.PaginationParams
  alias CcSpendingApi.Statements.Application.Commands.ListUserTransaction
  alias CcSpendingApi.Statements.Domain.Services.ListUserTransactionService

  def handle(_, deps \\ %{})

  def handle(%ListUserTransaction{} = command, deps) do
    with {:ok, base_query} = result <- build_base_query(command),
         {:ok, pagination_params} <- build_pagination_params(command, base_query),
         {:ok, result} <- Pagination.paginate(pagination_params) do
      {:ok, result}
    else
      error -> IO.inspect(error, label: "HANDLER ERROR ========================")
    end
  end

  defp build_base_query(command) do
    Result.ok(ListUserTransactionService.list_user_transaction(command))
  end

  defp build_pagination_params(%ListUserTransaction{} = command, base_query) do
    user_id = command.user_id
    filters = command.filters || %{}

    PaginationParams.new(base_query,
      cursor: command.cursor,
      # filters: Map.put(filters, :user_id, user_id),
      filters: filters,
      limit: command.limit,
      sort: command.sort
    )
  end
end
