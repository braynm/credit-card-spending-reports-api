defmodule CcSpendingApi.Statements.Domain.Entities.CardStatement do
  @moduledoc """
  Card Statement domain entity
  """

  @type t :: %__MODULE__{
          # id: String.t() | nil,
          id: String.t(),
          user_id: String.t(),
          file_checksum: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  defstruct [:id, :user_id, :file_checksum, :inserted_at, :updated_at]

  def new(params) do
    Result.ok(%__MODULE__{
      id: params["id"],
      user_id: params["user_id"],
      file_checksum: params["file_checksum"],
      inserted_at: params["inserted_at"],
      updated_at: params["inserted_at"]
    })
  end
end
