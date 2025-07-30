defmodule CcSpendingApi.Statements.Domain.Entities.Transaction do
  @moduledoc """
  Card Statement domain entity
  """

  @type t :: %__MODULE__{
          id: String.t(),
          user_id: String.t(),
          statement_id: String.t(),
          sale_date: String.t(),
          posted_date: DateTime.t(),
          description: DateTime.t(),
          amount: DateTime.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  defstruct [
    :id,
    :user_id,
    :statement_id,
    :sale_date,
    :posted_date,
    :description,
    :amount,
    :inserted_at,
    :updated_at
  ]

  def new(params) do
    # Result.ok(%__MODULE__{
    #   id: params["id"],
    #   user_id: params["user_id"],
    #   inserted_at: params["inserted_at"],
    #   updated_at: params["inserted_at"]
    # })
  end
end
