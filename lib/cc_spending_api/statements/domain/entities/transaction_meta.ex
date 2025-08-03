defmodule CcSpendingApi.Statements.Domain.Entities.TransactionMeta do
  @moduledoc """
  Card Statement domain entity
  """

  alias CcSpendingApi.Shared.Result
  alias CcSpendingApi.Statements.Domain.ValueObjects.Amount
  alias CcSpendingApi.Statements.Domain.Entities.Transaction

  @type t :: %__MODULE__{
          id: String.t() | nil,
          transaction_id: String.t(),
          details: String.t(),
          amount: integer()
        }

  defstruct [
    :id,
    :transaction_id,
    :details,
    :amount
  ]

  def new(params) do
    {:ok, amount} = Amount.new(params.amount)

    Result.ok(%__MODULE__{
      transaction_id: params.transaction_id,
      details: params.details,
      amount: Amount.to_string(amount)
    })
  end

  def from_transaction(params) do
    amount =
      cond do
        is_struct(params.amount) ->
          params.amount
          |> Decimal.to_string(:normal)
          |> String.to_integer()

        true ->
          {:ok, %Amount{amount: amount}} = Amount.new(params.amount)
          amount
          |> Decimal.to_string(:normal)
          |> String.to_integer()
      end

  Result.ok(
    %__MODULE__{
      transaction_id: params.id,
      details: params.details,
      amount: amount
    })
  end
end
