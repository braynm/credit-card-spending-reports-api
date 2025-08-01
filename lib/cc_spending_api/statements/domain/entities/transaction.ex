defmodule CcSpendingApi.Statements.Domain.Entities.Transaction do
  @moduledoc """
  Card Statement domain entity
  """

  alias CcSpendingApi.Shared.Result

  @type t :: %__MODULE__{
          user_id: String.t(),
          statement_id: String.t(),
          sale_date: DateTime.t(),
          posted_date: DateTime.t(),
          details: String.t(),
          amount: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  defstruct [
    :user_id,
    :statement_id,
    :sale_date,
    :posted_date,
    :details,
    :amount,
    :inserted_at,
    :updated_at
  ]

  def new(params) do
    Result.ok(%__MODULE__{
      user_id: params.user_id,
      statement_id: params.statement_id,
      sale_date: to_date_string(params.sale_date),
      posted_date: to_date_string(params.posted_date),
      details: params.encrypted_details,
      amount: params.encrypted_amount
    })
  end

  defp to_date_string(%DateTime{} = datetime) do
    datetime
    |> DateTime.to_date()
    |> Date.to_string()
  end
end
