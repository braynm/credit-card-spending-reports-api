defmodule CcSpendingApi.Statements.Infra.EctoCardStatementRepository do
  @behaviour CcSpendingApi.Statements.Domain.CardStatementRepo

  import Ecto.Query
  alias CcSpendingApi.Repo
  alias CcSpendingApi.Shared.{Result, Errors}
  alias CcSpendingApi.Utils.ValidatorFormatter
  alias CcSpendingApi.Statements.Domain.Entities.CardStatement
  alias CcSpendingApi.Statements.Infra.Schemas.CardStatementSchema

  def find_by_checksum(user_id, checksum) do
    query =
      from(q in CardStatementSchema,
        where:
          q.user_id == ^user_id and
            q.file_checksum == ^checksum
      )

    Repo.one(query)
  end

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
      {:error, changeset} -> Result.error(changeset_to_error(changeset))
    end
  end

  defp changeset_to_error(%Ecto.Changeset{valid?: false} = changeset) do
    ValidatorFormatter.first_errors_by_field(changeset)
  end
end
