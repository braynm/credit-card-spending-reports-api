defmodule CcSpendingApi.Statements.Infra.EctoTransactionRepository do
  @behaviour CcSpendingApi.Statements.Domain.TransactionRepo

  import Ecto.Query
  alias CcSpendingApi.Repo
  alias CcSpendingApi.Shared.Result
  alias CcSpendingApi.Statements.Domain.Entities.CardStatement
  alias CcSpendingApi.Statements.Infra.Schemas.CardStatementSchema

  def save_statement(%CardStatement{id: nil} = statement) do
    attrs = %{
      file_checksum: statement.file_checksum,
      filename: statement.filename,
      user_id: statement.user_id
    }

    %CardStatementSchema{}
    |> CardStatementSchema.changeset(attrs)
    |> Repo.insert()
    |> case do
      # {:ok, schema} -> Result.ok(to_domain(schema))
      {:ok, schema} -> Result.ok(schema)
      {:error, changeset} = error -> error
    end
  end
end
