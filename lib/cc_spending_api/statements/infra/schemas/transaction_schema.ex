defmodule CcSpendingApi.Statements.Infra.Schemas.TransactionSchema do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_transaction" do
    field :user_id, :integer
    field :statement_id, :integer
    field :sale_date, :utc_datetime
    field :posted_date, :utc_datetime
    field :encrypted_details, :string
    field :encrypted_amount, :string

    # TODO: add covered date? e.g. 2024-01-01 to 2024-02-01

    timestamps()
  end
end
