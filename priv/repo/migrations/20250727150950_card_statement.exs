defmodule CcSpendingApi.Repo.Migrations.CardStatement do
  use Ecto.Migration

  create table(:card_statement, primary_key: true) do
    add :user_id, references(:users, on_delete: :delete_all)
    add :file_checksum, :string

    timestamps()
  end
end
