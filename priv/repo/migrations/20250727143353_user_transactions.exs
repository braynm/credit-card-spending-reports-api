defmodule CcSpendingApi.Repo.Migrations.UserTransaction do
  use Ecto.Migration

  def change do
    create table(:card_statement, primary_key: true) do
      add :user_id, references(:user, on_delete: :delete_all)
      add :file_checksum, :string

      timestamps()
    end

    create table(:user_transaction, primary_key: true) do
      add :user_id, references(:user, on_delete: :delete_all)
      add :statement_id, references(:card_statement, on_delete: :delete_all)
      add :sale_date, :string
      add :posted_date, :string
      add :encrypted_details, :string
      add :encrypted_amount, :string

      timestamps()
    end

    create index(:user_transaction, [:user_id, :statement_id])

    create unique_index(:card_statement, [:user_id, :file_checksum])
  end
end
