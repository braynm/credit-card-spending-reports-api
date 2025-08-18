defmodule CcSpendingApi.Statements.Infra.Schemas.UserCardSchema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_card" do
    field :user_id, :integer
    field :bank, :string
    field :name, :string

    timestamps()
  end

  def changeset(%__MODULE__{} = card_statement, attrs) do
    card_statement
    |> cast(attrs, [:user_id, :file_checksum, :filename])
    |> validate_required([:user_id, :file_checksum, :filename])
  end
end
