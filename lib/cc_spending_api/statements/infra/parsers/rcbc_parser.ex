defmodule CcSpendingApi.Statements.Infra.Parsers.RcbcParser do
  @moduledoc """
  RCBC-specific PDF parser implementation
  All amounts are treated as PHP currency
  """

  @behaviour CcSpendingApi.Statements.Domain.BankParser
end
