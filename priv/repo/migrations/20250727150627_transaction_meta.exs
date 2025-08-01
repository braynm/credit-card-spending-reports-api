defmodule CcSpendingApi.Repo.Migrations.TransactionMeta do
  use Ecto.Migration

  def change do
    create table(:transaction_meta, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :transaction_id, references(:user_transaction, type: :uuid, on_delete: :delete_all)
      add :details, :string
      add :amount, :bigint

      timestamps()
    end
  end
end
