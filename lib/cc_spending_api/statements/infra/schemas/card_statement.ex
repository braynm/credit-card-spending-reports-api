defmodule CcSpendingApi.Statements.Infra.Schemas.CardStatement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "card_statement" do
    field :user_id, :integer
    field :file_checksum, :string

    # TODO: add covered date? e.g. 2024-01-01 to 2024-02-01

    timestamps()
  end

  def changeset(card_statement, attrs) do
    card_statement
    |> cast(attrs, [:user_id, :file_checksum])
    |> validate_required([:user_id, :file_checksum])
  end
end
