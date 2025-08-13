defmodule CcSpendingApi.Statements.Application.Handlers.ListUserTransactionHandler do
  alias CcSpendingApi.Shared.Result
  alias CcSpendingApi.Shared.Pagination
  alias CcSpendingApi.Shared.Pagination.PaginationParams
  alias CcSpendingApi.Statements.Application.Commands.ListUserTransaction
  alias CcSpendingApi.Statements.Domain.Services.ListUserTransactionService

  def handle(%ListUserTransaction{} = command, deps) do
    with {:ok, base_query} <- build_base_query(command, deps),
         {:ok, pagination_params} <- build_pagination_params(command, base_query) do
      Pagination.paginate(pagination_params, deps)
    end
  end

  defp build_base_query(command, deps) do
    Result.ok(ListUserTransactionService.list_user_transaction(command, deps))
  end

  defp build_pagination_params(%ListUserTransaction{} = command, base_query) do
    filters = command.filters || %{}

    # TODO: make a fnction in  pagination to wrap and isolate this
    PaginationParams.new(base_query,
      cursor: command.cursor,
      filters: filters,
      limit: command.limit,
      sort: command.sort
    )
  end
end
