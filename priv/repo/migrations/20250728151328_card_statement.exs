defmodule CcSpendingApi.Repo.Migrations.CardStatement do
  use Ecto.Migration

  def change do
    create table(:card_statement, primary_key: true) do
      add :user_id, references(:user, on_delete: :delete_all)
      add :file_checksum, :string

      timestamps()
    end
  end
end
