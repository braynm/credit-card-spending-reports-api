defmodule CcSpendingApi.Repo.Migrations.UserTransaction do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";")

    create table(:card_statement, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:user, on_delete: :delete_all)
      add :filename, :string
      add :file_checksum, :string

      timestamps(default: fragment("now()"), type: :utc_datetime)
    end

    create table(:user_transaction, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:user, on_delete: :delete_all)
      add :statement_id, references(:card_statement, type: :uuid, on_delete: :delete_all)
      add :sale_date, :utc_datetime
      add :posted_date, :utc_datetime
      add :encrypted_details, :binary
      add :encrypted_amount, :string

      timestamps(default: fragment("now()"), type: :utc_datetime)
    end

    create index(:user_transaction, [:user_id, :statement_id])

    create unique_index(:card_statement, [:user_id, :file_checksum])
  end

  def down do
    execute("DROP EXTENSION IF EXISTS \"uuid-ossp\";")
    execute("DROP table card_statement")
    execute("DROP table user_transaction")
  end
end
