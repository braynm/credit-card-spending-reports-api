defmodule CcSpendingApi.Repo.Migrations.UserTransaction do
  use Ecto.Migration

  def change do
    create table(:user_transaction, primary_key: true) do
      add :user_id, references(:user, on_delete: :delete_all)
      add :sale_date, :string
      add :posted_date, :string
      add :encrypted_details, :string
      add :encrypted_amount, :string

      timestamps()
    end

    create unique_index(:user_transaction, :user_id)
  end
end
