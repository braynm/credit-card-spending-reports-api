defmodule CcSpendingApi.Statements.Application.BankParser do
  @moduledoc """
  Behaviour for bank-specific PDF parsers
  """

  alias CcSpendingApi.Statements.Domain.Transaction
  alias CcSpendingApi.Shared.Result

  @callback parse(binary()) :: Result.t([Transaction.t()])
  @callback supported_bank() :: String.t()
  @callback validate_format(binary()) :: Result.t(boolean())
end
