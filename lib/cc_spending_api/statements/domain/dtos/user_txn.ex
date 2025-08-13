defmodule CcSpendingApi.Statements.Domain.Dtos.UserTxn do
  alias CcSpendingApi.Shared.Result
  alias CcSpendingApi.Statements.Infra.Schemas.TransactionSchema

  @type t :: %__MODULE__{
          id: String.t(),
          user_id: String.t(),
          sale_date: String.t(),
          posted_date: String.t(),
          details: String.t(),
          amount: String.t()
        }

  defstruct [:id, :user_id, :sale_date, :posted_date, :details, :amount]

  def new(%TransactionSchema{} = transaction) do
    Result.ok(%__MODULE__{
      id: transaction.id,
      user_id: transaction.user_id,
      sale_date: to_iso8601(transaction.sale_date),
      posted_date: to_iso8601(transaction.posted_date),
      details: transaction.encrypted_details,
      amount: transaction.encrypted_amount
    })
  end

  defp to_iso8601(%DateTime{} = datetime) do
    datetime
    |> DateTime.shift_zone!("Asia/Manila")
    |> DateTime.to_date()
    |> Date.to_iso8601()
  end
end
